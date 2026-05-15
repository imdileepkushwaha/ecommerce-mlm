using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.Services;
using System.Web.UI;

namespace EcommerceWebsite
{
    public partial class SellerInventory : System.Web.UI.Page
    {
        static string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;
        public int distinctProductCount = 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["SellerId"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                BindDashboard();
            }
        }

        private void BindDashboard()
        {
            int sellerId = Convert.ToInt32(Session["SellerId"]);
            LoadMetrics(sellerId);
            LoadInventoryGrid(sellerId);
        }

        private void LoadMetrics(int sellerId)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    string query = @"
                        SELECT 
                            COUNT(*) as DistinctProds,
                            ISNULL(SUM(Stock), 0) as TotalQty,
                            SUM(CASE WHEN Stock < 10 AND Stock > 0 THEN 1 ELSE 0 END) as LowStockCount,
                            SUM(CASE WHEN Stock <= 0 THEN 1 ELSE 0 END) as OutOfStockCount
                        FROM SellerProducts 
                        WHERE SellerId = @sid";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", sellerId);
                        con.Open();
                        SqlDataReader dr = cmd.ExecuteReader();
                        if (dr.Read())
                        {
                            litDistinctProducts.Text = dr["DistinctProds"].ToString();
                            litTotalQuantity.Text = dr["TotalQty"].ToString();
                            litLowStockCount.Text = dr["LowStockCount"].ToString();
                            litOutOfStockCount.Text = dr["OutOfStockCount"].ToString();
                        }
                        dr.Close();
                    }
                }
            }
            catch (Exception ex)
            {
                // Silent failure gracefully
            }
        }

        private void LoadInventoryGrid(int sellerId)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    string query = @"
                        SELECT 
                            p.Id, p.Name, p.Sku, p.Stock, p.MainImage, 
                            ISNULL(p.Category, 'Uncategorized') as Category,
                            (SELECT COUNT(*) FROM ProductVariants pv WHERE pv.ProductId = p.Id AND pv.VariantType='Size') as VariantCount
                        FROM SellerProducts p
                        WHERE p.SellerId = @sid
                        ORDER BY p.CreatedAt DESC";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", sellerId);

                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        
                        distinctProductCount = dt.Rows.Count;

                        gvInventory.DataSource = dt;
                        gvInventory.DataBind();
                    }
                }
            }
            catch (Exception ex)
            {
                // Handled
            }
        }

        // UI Render Utilities
        protected string GetProductImage(object dbPath)
        {
            string path = dbPath != DBNull.Value && !string.IsNullOrEmpty(dbPath.ToString()) ? dbPath.ToString() : "";
            if (string.IsNullOrEmpty(path)) return "/assets/images/no-image.png";

            if (path.StartsWith("http", StringComparison.OrdinalIgnoreCase)) return path;
            
            string cleanPath = path.Replace("~", "");
            if (!cleanPath.StartsWith("/")) cleanPath = "/" + cleanPath;
            return cleanPath;
        }

        protected string GetStockPillClass(object stockVal)
        {
            int s = 0;
            if (stockVal != DBNull.Value) int.TryParse(stockVal.ToString(), out s);

            if (s <= 0) return "stock-pill out";
            if (s < 10) return "stock-pill low";
            return "stock-pill good";
        }

        // ============================================================
        // ASYNCHRONOUS WEBMETHOD APIS FOR INTERACTIVE INVENTORY UPDATES
        // ============================================================

        [WebMethod]
        public static List<VariantDTO> GetProductVariants(int productId)
        {
            List<VariantDTO> list = new List<VariantDTO>();
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    string q = "SELECT Id, VariantValue, Sku, Stock FROM ProductVariants WHERE ProductId = @pid AND VariantType='Size' ORDER BY Id ASC";
                    using (SqlCommand cmd = new SqlCommand(q, con))
                    {
                        cmd.Parameters.AddWithValue("@pid", productId);
                        con.Open();
                        SqlDataReader dr = cmd.ExecuteReader();
                        while (dr.Read())
                        {
                            list.Add(new VariantDTO
                            {
                                Id = Convert.ToInt32(dr["Id"]),
                                Value = dr["VariantValue"].ToString(),
                                Sku = dr["Sku"] != DBNull.Value ? dr["Sku"].ToString() : "",
                                Stock = Convert.ToInt32(dr["Stock"])
                            });
                        }
                        dr.Close();
                    }
                }
            }
            catch { }
            return list;
        }

        [WebMethod]
        public static AjaxResult UpdateVariantStocks(int productId, string dataString)
        {
            if (string.IsNullOrEmpty(dataString))
            {
                return new AjaxResult { success = false, message = "Operational payload was empty." };
            }

            try
            {
                string[] items = dataString.Split('|');
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    using (SqlTransaction trans = con.BeginTransaction())
                    {
                        try
                        {
                            // 1. Save new individual stock values
                            string updateVariantSql = "UPDATE ProductVariants SET Stock = @stk WHERE Id = @vid AND ProductId = @pid";
                            foreach (string item in items)
                            {
                                string[] parts = item.Split(':');
                                if (parts.Length == 2)
                                {
                                    int vid = Convert.ToInt32(parts[0]);
                                    int stock = Convert.ToInt32(parts[1]);

                                    using (SqlCommand cmd = new SqlCommand(updateVariantSql, con, trans))
                                    {
                                        cmd.Parameters.AddWithValue("@stk", stock);
                                        cmd.Parameters.AddWithValue("@vid", vid);
                                        cmd.Parameters.AddWithValue("@pid", productId);
                                        cmd.ExecuteNonQuery();
                                    }
                                }
                            }

                            // 2. Tabulate current variant reserves and update the parent Master product Stock!
                            // (Ensures accurate cumulative data synchronization!)
                            string syncParentSql = @"
                                UPDATE SellerProducts 
                                SET Stock = (SELECT ISNULL(SUM(Stock), 0) FROM ProductVariants WHERE ProductId = @pid AND VariantType='Size')
                                WHERE Id = @pid";

                            using (SqlCommand syncCmd = new SqlCommand(syncParentSql, con, trans))
                            {
                                syncCmd.Parameters.AddWithValue("@pid", productId);
                                syncCmd.ExecuteNonQuery();
                            }

                            trans.Commit();
                            return new AjaxResult { success = true };
                        }
                        catch (Exception ex)
                        {
                            trans.Rollback();
                            return new AjaxResult { success = false, message = ex.Message };
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                return new AjaxResult { success = false, message = ex.Message };
            }
        }

        [WebMethod]
        public static AjaxResult UpdateGlobalStock(int productId, int stock)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    string sql = "UPDATE SellerProducts SET Stock = @stk WHERE Id = @pid";
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@stk", stock);
                        cmd.Parameters.AddWithValue("@pid", productId);
                        con.Open();
                        cmd.ExecuteNonQuery();
                    }
                }
                return new AjaxResult { success = true };
            }
            catch (Exception ex)
            {
                return new AjaxResult { success = false, message = ex.Message };
            }
        }

        // Data Transfer Classes
        public class VariantDTO
        {
            public int Id { get; set; }
            public string Value { get; set; }
            public string Sku { get; set; }
            public int Stock { get; set; }
        }

        public class AjaxResult
        {
            public bool success { get; set; }
            public string message { get; set; }
        }
    }
}
