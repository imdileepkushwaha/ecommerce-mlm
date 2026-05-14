using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ecommerce_mlm
{
    public partial class Cart : System.Web.UI.Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;
        decimal _subtotal = 0;
        int _totalItems = 0;

        public string ConfigMinFreeShipping = "1000";
        public string ConfigShippingFee = "25";
        public string ConfigPlatformFee = "5";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadRuntimeSettings();
                litShippingVisual.Text = "₹ " + ConfigShippingFee;
                
                LoadCartItems();
                LoadSavedForLater();
            }
        }

        private void LoadSavedForLater()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    string query = @"SELECT c.*, p.Name, p.Price, p.Mrp, p.MainImage, p.Brand 
                                     FROM CartItems c 
                                     INNER JOIN SellerProducts p ON c.ProductId = p.Id 
                                     WHERE c.SessionId = @sid AND c.IsSavedForLater = 1
                                     ORDER BY c.AddedDate DESC";
                    
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", Session.SessionID);
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            rptSavedForLater.DataSource = dt;
                            rptSavedForLater.DataBind();
                            pnlSavedForLaterSection.Visible = true;
                            litSavedCount.Text = dt.Rows.Count.ToString();
                        }
                        else
                        {
                            // Disabled auto-hide for user verification
                            // pnlSavedForLaterSection.Visible = false; 
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Response.Write("<div style='display:none'>SAVED ERROR: " + ex.Message + "</div>");
            }
        }

        private void LoadCartItems()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    string query = @"SELECT c.*, p.Name, p.Price, p.Mrp, p.MainImage, p.Brand, p.Stock 
                                     FROM CartItems c 
                                     INNER JOIN SellerProducts p ON c.ProductId = p.Id 
                                     WHERE c.SessionId = @sid AND c.IsSavedForLater = 0
                                     ORDER BY c.AddedDate DESC";
                    
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", Session.SessionID);
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            rptCart.DataSource = dt;
                            rptCart.DataBind();

                            pnlEmptyCart.Visible = false;
                            
                            // Update top, breadcrumb & bottom labels
                            string finalCountStr = dt.Rows.Count.ToString();
                            litCartCountTop.Text = finalCountStr;
                            litCartCountBreadcrumb.Text = finalCountStr;
                            litItemsCountBottom.Text = finalCountStr;

                            // Subtotal loop
                            foreach(DataRow row in dt.Rows)
                            {
                                decimal price = Convert.ToDecimal(row["Price"]);
                                int qty = Convert.ToInt32(row["Quantity"]);
                                _subtotal += (price * qty);
                            }

                            litSubtotal.Text = _subtotal.ToString("N0");
                            
                            
                            // Parsing dynamic fee runtime configs

                            decimal minFree = 1000; decimal.TryParse(ConfigMinFreeShipping, out minFree);
                            decimal shipFee = 25; decimal.TryParse(ConfigShippingFee, out shipFee);
                            decimal platFee = 5; decimal.TryParse(ConfigPlatformFee, out platFee);

                            // Calculate Total with dynamic shipping based on promo threshold 
                            decimal shipping = _subtotal >= minFree ? 0 : shipFee;
                            decimal finalTotal = _subtotal + shipping + platFee;
                            
                            // Set visual indicator (Green FREE or Currency Amount)
                            if (shipping == 0)
                            {
                                litShippingVisual.Text = "<span style='color:#10b981; font-weight:800;'>FREE</span>";
                            }
                            else
                            {
                                litShippingVisual.Text = "₹ " + shipping.ToString();
                            }
                            
                            litTotalAmount.Text = finalTotal.ToString("N0");
                        }
                        else
                        {
                            rptCart.Visible = false;
                            pnlEmptyCart.Visible = true;
                            litCartCountTop.Text = "0";
                            litCartCountBreadcrumb.Text = "0";
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Response.Write("<script>alert('Error: " + ex.Message + "');</script>");
            }
        }

        private void LoadRuntimeSettings()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string sql = "SELECT ConfigKey, ConfigValue FROM SystemSettings WHERE ConfigKey IN ('PlatformFee', 'MinFreeShipping', 'ShippingFee')";
                    SqlCommand cmd = new SqlCommand(sql, con);
                    SqlDataReader dr = cmd.ExecuteReader();
                    while (dr.Read())
                    {
                        string key = dr["ConfigKey"].ToString();
                        string val = dr["ConfigValue"].ToString();
                        if (key == "MinFreeShipping") ConfigMinFreeShipping = val;
                        else if (key == "ShippingFee") ConfigShippingFee = val;
                        else if (key == "PlatformFee") ConfigPlatformFee = val;
                    }
                }
            }
            catch { }
        }

        protected void rptCart_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            // Can extend if runtime bound manipulations are required
        }

        protected string GetDiscountPercentage(object price, object mrp)
        {
            try
            {
                if (price != null && mrp != null && price != DBNull.Value && mrp != DBNull.Value)
                {
                    decimal p = Convert.ToDecimal(price);
                    decimal m = Convert.ToDecimal(mrp);
                    if (m > 0 && m > p)
                    {
                        decimal discount = ((m - p) / m) * 100;
                        return Math.Round(discount).ToString() + "%";
                    }
                }
                return "0%";
            }
            catch
            {
                return "0%";
            }
        }
        protected void btnCheckout_Click(object sender, EventArgs e)
        {
            if (Session["UserId"] != null)
            {
                Response.Redirect("Checkout.aspx");
            }
            else
            {
                Response.Redirect("Login.aspx");
            }
        }
    }
}
