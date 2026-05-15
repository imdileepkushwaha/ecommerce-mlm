using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace EcommerceWebsite
{
    public partial class SellerProducts : System.Web.UI.Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;
        
        // Public statistics variables for front-end stat cards
        public int totalListings = 0;
        public int liveListings = 0;
        public int pendingListings = 0;
        public int lowStockListings = 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["SellerId"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadDashboardStats();
                BindProducts();
            }
        }

        private void LoadDashboardStats()
        {
            if (Session["SellerId"] == null) return;
            int sid = Convert.ToInt32(Session["SellerId"]);

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    // Optimized aggregate query to grab metrics in one go
                    string sql = @"
                        SELECT 
                            COUNT(*) AS TotalCount,
                            SUM(CASE WHEN IsActive = 1 AND (ListingStatus = 'Active' OR ListingStatus = 'Approved') THEN 1 ELSE 0 END) AS LiveCount,
                            SUM(CASE WHEN ListingStatus = 'Pending' THEN 1 ELSE 0 END) AS PendingCount,
                            SUM(CASE WHEN Stock < 5 THEN 1 ELSE 0 END) AS LowStockCount
                        FROM SellerProducts WHERE SellerId = @sid";

                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", sid);
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                totalListings = dr["TotalCount"] != DBNull.Value ? Convert.ToInt32(dr["TotalCount"]) : 0;
                                liveListings = dr["LiveCount"] != DBNull.Value ? Convert.ToInt32(dr["LiveCount"]) : 0;
                                pendingListings = dr["PendingCount"] != DBNull.Value ? Convert.ToInt32(dr["PendingCount"]) : 0;
                                lowStockListings = dr["LowStockCount"] != DBNull.Value ? Convert.ToInt32(dr["LowStockCount"]) : 0;
                            }
                        }
                    }
                }
            }
            catch { }
        }

        private void BindProducts()
        {
            if (Session["SellerId"] == null) return;
            int sid = Convert.ToInt32(Session["SellerId"]);

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    // HIGH PERFORMANCE OPTIMIZATION: Select only the UI-relevant subset of columns. 
                    // Purged SELECT * to block loading of heavy Nvarchar(MAX) assets like 'Description', 'GalleryUrls', 'MetaDescription', etc.
                    string sql = @"
                        SELECT 
                            Id, 
                            Name, 
                            Slug, 
                            Sku, 
                            Category, 
                            Price, 
                            Mrp, 
                            Stock, 
                            ListingStatus, 
                            IsActive, 
                            CreatedAt, 
                            ThumbnailUrl, 
                            MainImage 
                        FROM SellerProducts 
                        WHERE SellerId = @sid 
                        ORDER BY Id DESC";
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", sid);
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            rptProducts.DataSource = dt;
                            rptProducts.DataBind();
                            rptProducts.Visible = true;
                            phEmptyState.Visible = false;
                        }
                        else
                        {
                            rptProducts.DataSource = null;
                            rptProducts.DataBind();
                            rptProducts.Visible = false;
                            phEmptyState.Visible = true;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMsg("Catalog Stream Interruption: " + ex.Message, true);
            }
        }

        protected void rptProducts_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (Session["SellerId"] == null) return;
            int sid = Convert.ToInt32(Session["SellerId"]);
            int productId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "ToggleActive")
            {
                try
                {
                    using (SqlConnection con = new SqlConnection(strcon))
                    {
                        con.Open();
                        // Programmatic Inversion of Boolean state via SQL bitwise XOR/NOT
                        string sql = "UPDATE SellerProducts SET IsActive = ~IsActive, UpdatedAt = GETDATE() WHERE Id = @pid AND SellerId = @sid";
                        using (SqlCommand cmd = new SqlCommand(sql, con))
                        {
                            cmd.Parameters.AddWithValue("@pid", productId);
                            cmd.Parameters.AddWithValue("@sid", sid);
                            cmd.ExecuteNonQuery();
                        }
                    }
                    BindProducts(); // Instant Refresh
                    LoadDashboardStats(); // Refresh stats as well
                    ShowMsg("⚡ Product visibility state updated successfully.", false);
                }
                catch (Exception ex)
                {
                    ShowMsg("Switch Action Failure: " + ex.Message, true);
                }
            }
            else if (e.CommandName == "DeleteProduct")
            {
                try
                {
                    using (SqlConnection con = new SqlConnection(strcon))
                    {
                        con.Open();
                        string sql = "DELETE FROM SellerProducts WHERE Id = @pid AND SellerId = @sid";
                        using (SqlCommand cmd = new SqlCommand(sql, con))
                        {
                            cmd.Parameters.AddWithValue("@pid", productId);
                            cmd.Parameters.AddWithValue("@sid", sid);
                            cmd.ExecuteNonQuery();
                        }
                    }
                    BindProducts(); // Instant Refresh
                    LoadDashboardStats();
                    ShowMsg("🗑️ Product removed permanently from catalog inventory.", false);
                }
                catch (Exception ex)
                {
                    ShowMsg("Deletion Pipeline Failure: " + ex.Message, true);
                }
            }
        }

        #region Markup Helpers

        protected string GetProductImage(object thumbUrl, object mainImage)
        {
            string path = thumbUrl != DBNull.Value && !string.IsNullOrEmpty(thumbUrl.ToString()) 
                          ? thumbUrl.ToString() 
                          : (mainImage != DBNull.Value && !string.IsNullOrEmpty(mainImage.ToString()) ? mainImage.ToString() : "");

            if (!string.IsNullOrEmpty(path))
            {
                // Handle Absolute External HTTPS / HTTP Pathways directly
                if (path.StartsWith("http://", StringComparison.OrdinalIgnoreCase) || 
                    path.StartsWith("https://", StringComparison.OrdinalIgnoreCase) || 
                    path.StartsWith("//"))
                {
                    return string.Format("<img src='{0}' class='p-thumb-img' alt='item' />", path);
                }

                // Handle Local Relational Virtual pathways
                string cleanPath = path.StartsWith("~") ? path.Substring(1) : path;
                if (!cleanPath.StartsWith("/")) cleanPath = "/" + cleanPath;
                return string.Format("<img src='{0}' class='p-thumb-img' alt='item' />", cleanPath);
            }

            return "<i class='fas fa-image p-thumb-placeholder'></i>";
        }

        protected string GetStockBadge(object stockVal)
        {
            int stock = stockVal != DBNull.Value ? Convert.ToInt32(stockVal) : 0;
            if (stock <= 0)
            {
                return "<span class='stock-count stock-out'><i class='fas fa-circle-exclamation u-mr-5'></i>Out Of Stock</span>";
            }
            else if (stock < 10)
            {
                return string.Format("<span class='stock-count stock-low'><i class='fas fa-triangle-exclamation u-mr-5'></i>Low: {0} left</span>", stock);
            }
            else
            {
                return string.Format("<span class='stock-count' style='color: #059669;'><i class='fas fa-circle-check u-mr-5'></i>{0} in Stock</span>", stock);
            }
        }

        protected string GetStatusBadge(object isActiveVal)
        {
            bool active = isActiveVal != DBNull.Value ? Convert.ToBoolean(isActiveVal) : false;
            if (active)
            {
                return "<span class='badge-pill badge-pill-active'><i class='fas fa-globe'></i> Active</span>";
            }
            else
            {
                return "<span class='badge-pill badge-pill-inactive'><i class='fas fa-eye-slash'></i> Inactive</span>";
            }
        }

        protected string GetListingStatusBadge(object listingStatus)
        {
            string status = listingStatus != DBNull.Value ? listingStatus.ToString().Trim() : "Pending";
            if (status.Equals("Active", StringComparison.OrdinalIgnoreCase) || status.Equals("Approved", StringComparison.OrdinalIgnoreCase))
            {
                return "<span class='p-badge-success'>Approved</span>";
            }
            else
            {
                return "<span class='p-badge-warning'>Pending</span>";
            }
        }

        #endregion

        private void ShowMsg(string msg, bool isError)
        {
            lblGlobalMsg.Text = msg;
            lblGlobalMsg.Visible = true;
            
            if (isError)
            {
                lblGlobalMsg.BackColor = System.Drawing.Color.FromName("#fef2f2");
                lblGlobalMsg.ForeColor = System.Drawing.Color.FromName("#dc2626");
                lblGlobalMsg.Style["border"] = "1px solid #fecaca";
            }
            else
            {
                lblGlobalMsg.BackColor = System.Drawing.Color.FromName("#f0fdf4");
                lblGlobalMsg.ForeColor = System.Drawing.Color.FromName("#16a34a");
                lblGlobalMsg.Style["border"] = "1px solid #bbf7d0";
            }
            
            upnlMsg.Update();
        }
    }
}
