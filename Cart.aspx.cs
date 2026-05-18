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
                
                if (Session["AppliedCouponCode"] != null)
                {
                    string code = Session["AppliedCouponCode"].ToString();
                    hfAppliedCouponCode.Value = code;
                    PopulateCouponMetadata(code);
                }

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

                            // Parse active coupon discount if populated
                            decimal discount = 0;
                            string couponCode = hfAppliedCouponCode.Value.Trim().ToUpper();
                            if (!string.IsNullOrEmpty(couponCode))
                            {
                                decimal.TryParse(hfCouponDiscountAmount.Value, out discount);
                                pnlDiscountRow.Visible = discount > 0;
                                pnlActiveCoupon.Visible = discount > 0;
                                litDiscountAmt.Text = discount.ToString("N0");
                                litActiveCode.Text = couponCode + " (-₹" + discount.ToString("N0") + ")";
                            }
                            else
                            {
                                pnlDiscountRow.Visible = false;
                                pnlActiveCoupon.Visible = false;
                            }

                            // Calculate Total with dynamic shipping based on promo threshold 
                            decimal shipping = _subtotal >= minFree ? 0 : shipFee;
                            decimal finalTotal = _subtotal + shipping + platFee - discount;
                            if (finalTotal < 0) finalTotal = 0;
                            
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

        protected void btnApplyCoupon_Click(object sender, EventArgs e)
        {
            lblCouponMsg.Visible = false;
            string code = txtCouponCode.Text.Trim().ToUpper();
            if (string.IsNullOrEmpty(code))
            {
                lblCouponMsg.Text = "❌ Please enter a coupon code.";
                lblCouponMsg.CssClass = "text-danger";
                lblCouponMsg.Visible = true;
                return;
            }

            Session["AppliedCouponCode"] = code;
            hfAppliedCouponCode.Value = code;

            decimal subtotalVal = GetCartSubtotal();

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string qC = "SELECT * FROM Coupons WHERE CouponCode = @code AND IsActive = 1 AND StartDate <= GETDATE() AND EndDate >= GETDATE()";
                    using (SqlCommand cmd = new SqlCommand(qC, con))
                    {
                        cmd.Parameters.AddWithValue("@code", code);
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                decimal minSpend = Convert.ToDecimal(dr["MinOrderAmount"]);
                                int used = Convert.ToInt32(dr["UsedCount"]);
                                int limit = Convert.ToInt32(dr["UsageLimit"]);

                                if (subtotalVal < minSpend)
                                {
                                    lblCouponMsg.Text = "❌ Minimum spend of ₹" + minSpend.ToString("N0") + " is required to use this coupon.";
                                    lblCouponMsg.CssClass = "text-danger";
                                    lblCouponMsg.Visible = true;
                                    ClearCouponState();
                                }
                                else if (used >= limit)
                                {
                                    lblCouponMsg.Text = "❌ This coupon limit has been fully redeemed.";
                                    lblCouponMsg.CssClass = "text-danger";
                                    lblCouponMsg.Visible = true;
                                    ClearCouponState();
                                }
                                else
                                {
                                    string distType = dr["DiscountType"].ToString();
                                    decimal distVal = Convert.ToDecimal(dr["DiscountValue"]);
                                    decimal maxCap = dr["MaxDiscountAmount"] != DBNull.Value ? Convert.ToDecimal(dr["MaxDiscountAmount"]) : 0;

                                    hfDiscountType.Value = distType;
                                    hfDiscountValue.Value = distVal.ToString();
                                    hfMinOrderAmount.Value = minSpend.ToString();
                                    hfMaxDiscountAmount.Value = maxCap.ToString();

                                    decimal discount = 0;
                                    if (distType == "Percentage")
                                    {
                                        discount = subtotalVal * (distVal / 100);
                                        if (maxCap > 0)
                                        {
                                            discount = Math.Min(discount, maxCap);
                                        }
                                    }
                                    else
                                    {
                                        discount = Math.Min(distVal, subtotalVal);
                                    }

                                    hfCouponDiscountAmount.Value = discount.ToString("F2");
                                    litDiscountAmt.Text = discount.ToString("N0");
                                    pnlDiscountRow.Visible = true;
                                    pnlActiveCoupon.Visible = true;
                                    litActiveCode.Text = code + " (-₹" + discount.ToString("N0") + ")";

                                    lblCouponMsg.Text = "🎉 Coupon applied! Saved ₹" + discount.ToString("F0");
                                    lblCouponMsg.CssClass = "text-success";
                                    lblCouponMsg.Visible = true;
                                }
                            }
                            else
                            {
                                lblCouponMsg.Text = "❌ Invalid, inactive, or expired coupon code.";
                                lblCouponMsg.CssClass = "text-danger";
                                lblCouponMsg.Visible = true;
                                ClearCouponState();
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                lblCouponMsg.Text = "❌ Error applying coupon: " + ex.Message;
                lblCouponMsg.CssClass = "text-danger";
                lblCouponMsg.Visible = true;
                ClearCouponState();
            }

            LoadCartItems();
            txtCouponCode.Text = "";
        }

        protected void btnRemoveCoupon_Click(object sender, EventArgs e)
        {
            ClearCouponState();
            lblCouponMsg.Text = "ℹ️ Coupon code removed.";
            lblCouponMsg.CssClass = "text-muted";
            lblCouponMsg.Visible = true;

            LoadCartItems();
            txtCouponCode.Text = "";
        }

        private void PopulateCouponMetadata(string code)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string q = "SELECT * FROM Coupons WHERE CouponCode = @code AND IsActive = 1 AND StartDate <= GETDATE() AND EndDate >= GETDATE()";
                    using (SqlCommand cmd = new SqlCommand(q, con))
                    {
                        cmd.Parameters.AddWithValue("@code", code);
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                hfDiscountType.Value = dr["DiscountType"].ToString();
                                hfDiscountValue.Value = Convert.ToDecimal(dr["DiscountValue"]).ToString();
                                hfMinOrderAmount.Value = Convert.ToDecimal(dr["MinOrderAmount"]).ToString();
                                hfMaxDiscountAmount.Value = dr["MaxDiscountAmount"] != DBNull.Value ? Convert.ToDecimal(dr["MaxDiscountAmount"]).ToString() : "0";

                                decimal minSpend = Convert.ToDecimal(dr["MinOrderAmount"]);
                                decimal subtotalVal = GetCartSubtotal();
                                if (subtotalVal >= minSpend)
                                {
                                    string distType = dr["DiscountType"].ToString();
                                    decimal distVal = Convert.ToDecimal(dr["DiscountValue"]);
                                    decimal maxCap = dr["MaxDiscountAmount"] != DBNull.Value ? Convert.ToDecimal(dr["MaxDiscountAmount"]) : 0;

                                    decimal discount = 0;
                                    if (distType == "Percentage")
                                    {
                                        discount = subtotalVal * (distVal / 100);
                                        if (maxCap > 0) discount = Math.Min(discount, maxCap);
                                    }
                                    else
                                    {
                                        discount = Math.Min(distVal, subtotalVal);
                                    }

                                    hfCouponDiscountAmount.Value = discount.ToString("F2");
                                }
                                else
                                {
                                    ClearCouponState();
                                }
                            }
                            else
                            {
                                ClearCouponState();
                            }
                        }
                    }
                }
            }
            catch
            {
                ClearCouponState();
            }
        }

        private decimal GetCartSubtotal()
        {
            decimal total = 0;
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    string query = @"SELECT c.Quantity, p.Price 
                                     FROM CartItems c 
                                     INNER JOIN SellerProducts p ON c.ProductId = p.Id 
                                     WHERE c.SessionId = @sid AND c.IsSavedForLater = 0";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", Session.SessionID);
                        con.Open();
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            while (dr.Read())
                            {
                                int qty = Convert.ToInt32(dr["Quantity"]);
                                decimal price = Convert.ToDecimal(dr["Price"]);
                                total += (price * qty);
                            }
                        }
                    }
                }
            }
            catch { }
            return total;
        }

        private void ClearCouponState()
        {
            Session["AppliedCouponCode"] = null;
            hfAppliedCouponCode.Value = "";
            hfCouponDiscountAmount.Value = "0";
            hfDiscountType.Value = "";
            hfDiscountValue.Value = "0";
            hfMinOrderAmount.Value = "0";
            hfMaxDiscountAmount.Value = "0";
            pnlDiscountRow.Visible = false;
            pnlActiveCoupon.Visible = false;
        }
    }
}
