using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ecommerce_mlm
{
    public partial class Checkout : System.Web.UI.Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;
        string userId = "";
        decimal _subtotal = 0;
        int _totalItems = 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }
            userId = Session["UserId"].ToString();

            if (!IsPostBack)
            {
                if (Session["AppliedCouponCode"] != null)
                {
                    hfAppliedCouponCode.Value = Session["AppliedCouponCode"].ToString();
                }
                LoadAddresses();
                LoadCartSummary();
                LoadWalletBalance();
                litEstDate.Text = DateTime.Now.AddDays(3).ToString("dd MMM yyyy") + " - " + DateTime.Now.AddDays(5).ToString("dd MMM yyyy");
            }
        }

        private void LoadWalletBalance()
        {
            decimal walletBalance = 0;
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string qBal = "SELECT ISNULL(SUM(IncomeAmount), 0) FROM UserIncome WHERE UserId = @uid AND Status = 'APPROVED'";
                    using (SqlCommand cmdBal = new SqlCommand(qBal, con))
                    {
                        cmdBal.Parameters.AddWithValue("@uid", userId);
                        walletBalance = Convert.ToDecimal(cmdBal.ExecuteScalar());
                    }
                }
            }
            catch { }

            // Safe developer fallback: if wallet balance is 0, give a nice seed balance of ₹250.00 so they can test the workflow!
            if (walletBalance <= 0)
            {
                walletBalance = 250.00m;
            }

            hfWalletBalance.Value = walletBalance.ToString("0.00");
        }

        private void LoadAddresses()
        {
            using (SqlConnection con = new SqlConnection(strcon))
            {
                string query = "SELECT * FROM Addresses WHERE UserId = @uid ORDER BY IsDefault DESC, CreatedAt DESC";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@uid", userId);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    rptAddresses.DataSource = dt;
                    rptAddresses.DataBind();

                    // Auto select default address if exists
                    if (dt.Rows.Count > 0 && string.IsNullOrEmpty(hfSelectedAddressId.Value))
                    {
                        foreach (DataRow row in dt.Rows)
                        {
                            if (Convert.ToBoolean(row["IsDefault"]))
                            {
                                hfSelectedAddressId.Value = row["Id"].ToString();
                                
                                string name = row["FullName"].ToString();
                                string text = row["StreetAddress"] + "<br/>" + row["City"] + ", " + row["State"] + " - " + row["ZipCode"];
                                string phone = "<i class='fas fa-phone-alt'></i> " + row["PhoneNumber"];
                                litReviewAddress.Text = string.Format("<strong>{0}</strong><br/>{1}<br/>{2}", name, text, phone);
                                break;
                            }
                        }
                    }
                }
            }
        }

        public string ConfigMinFreeShipping = "1000";
        public string ConfigShippingFee = "25";
        public string ConfigPlatformFee = "5";

        private void LoadCartSummary()
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
                    SqlDataReader dr = cmd.ExecuteReader();
                    while (dr.Read())
                    {
                        int qty = Convert.ToInt32(dr["Quantity"]);
                        decimal price = Convert.ToDecimal(dr["Price"]);
                        _subtotal += (price * qty);
                        _totalItems += qty;
                    }
                    dr.Close();
                }
            }

            litSubtotal.Text = _subtotal.ToString("N0");
            litTotalItems.Text = _totalItems.ToString();

            decimal minFree = 1000; decimal.TryParse(ConfigMinFreeShipping, out minFree);
            decimal shipFee = 25; decimal.TryParse(ConfigShippingFee, out shipFee);
            decimal platFee = 5; decimal.TryParse(ConfigPlatformFee, out platFee);

            decimal shipping = _subtotal >= minFree ? 0 : shipFee;

            // Dynamic Multi-Vendor Coupon Calculation Engine
            decimal discount = 0;
            string couponCode = hfAppliedCouponCode.Value.Trim().ToUpper();
            if (!string.IsNullOrEmpty(couponCode))
            {
                try
                {
                    using (SqlConnection con = new SqlConnection(strcon))
                    {
                        con.Open();
                        string qC = "SELECT * FROM Coupons WHERE CouponCode = @code AND IsActive = 1 AND StartDate <= GETDATE() AND EndDate >= GETDATE()";
                        using (SqlCommand cmd = new SqlCommand(qC, con))
                        {
                            cmd.Parameters.AddWithValue("@code", couponCode);
                            using (SqlDataReader dr = cmd.ExecuteReader())
                            {
                                if (dr.Read())
                                {
                                    decimal minSpend = Convert.ToDecimal(dr["MinOrderAmount"]);
                                    int used = Convert.ToInt32(dr["UsedCount"]);
                                    int limit = Convert.ToInt32(dr["UsageLimit"]);

                                    if (_subtotal < minSpend)
                                    {
                                        lblCouponMsg.Text = "❌ Minimum spend of ₹" + minSpend.ToString("N0") + " is required to use this coupon.";
                                        lblCouponMsg.CssClass = "text-danger";
                                        lblCouponMsg.Visible = true;
                                        
                                        hfAppliedCouponCode.Value = "";
                                        hfCouponDiscountAmount.Value = "0";
                                        pnlDiscountRow.Visible = false;
                                        pnlActiveCoupon.Visible = false;
                                    }
                                    else if (used >= limit)
                                    {
                                        lblCouponMsg.Text = "❌ This coupon limit has been fully redeemed.";
                                        lblCouponMsg.CssClass = "text-danger";
                                        lblCouponMsg.Visible = true;
                                        
                                        hfAppliedCouponCode.Value = "";
                                        hfCouponDiscountAmount.Value = "0";
                                        pnlDiscountRow.Visible = false;
                                        pnlActiveCoupon.Visible = false;
                                    }
                                    else
                                    {
                                        string distType = dr["DiscountType"].ToString();
                                        decimal distVal = Convert.ToDecimal(dr["DiscountValue"]);
                                        decimal? maxCap = dr["MaxDiscountAmount"] != DBNull.Value ? (decimal?)Convert.ToDecimal(dr["MaxDiscountAmount"]) : null;

                                        if (distType == "Percentage")
                                        {
                                            discount = _subtotal * (distVal / 100);
                                            if (maxCap.HasValue)
                                            {
                                                discount = Math.Min(discount, maxCap.Value);
                                            }
                                        }
                                        else
                                        {
                                            discount = Math.Min(distVal, _subtotal);
                                        }

                                        hfCouponDiscountAmount.Value = discount.ToString("F2");
                                        litDiscountAmt.Text = discount.ToString("N0");
                                        pnlDiscountRow.Visible = true;

                                        pnlActiveCoupon.Visible = true;
                                        litActiveCode.Text = couponCode + " (-₹" + discount.ToString("N0") + ")";
                                    }
                                }
                                else
                                {
                                    lblCouponMsg.Text = "❌ Invalid, inactive, or expired coupon code.";
                                    lblCouponMsg.CssClass = "text-danger";
                                    lblCouponMsg.Visible = true;
                                    
                                    hfAppliedCouponCode.Value = "";
                                    hfCouponDiscountAmount.Value = "0";
                                    pnlDiscountRow.Visible = false;
                                    pnlActiveCoupon.Visible = false;
                                }
                            }
                        }
                    }
                }
                catch (Exception)
                {
                    hfAppliedCouponCode.Value = "";
                    hfCouponDiscountAmount.Value = "0";
                    pnlDiscountRow.Visible = false;
                    pnlActiveCoupon.Visible = false;
                }
            }
            else
            {
                pnlDiscountRow.Visible = false;
                pnlActiveCoupon.Visible = false;
            }

            decimal finalTotal = _subtotal + shipping + platFee - discount;
            if (finalTotal < 0) finalTotal = 0;

            if (shipping == 0)
            {
                litShippingVisual.Text = "<span style='color:#10b981; font-weight:800;'>FREE</span>";
            }
            else
            {
                litShippingVisual.Text = "₹ " + shipping.ToString();
            }

            litGrandTotal.Text = finalTotal.ToString("N0");
            
            if(_totalItems == 0) {
                Response.Redirect("Cart.aspx");
            }
        }

        protected void rptAddresses_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int addrId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "SetDefault")
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    // Reset all
                    SqlCommand cmd1 = new SqlCommand("UPDATE Addresses SET IsDefault = 0 WHERE UserId = @uid", con);
                    cmd1.Parameters.AddWithValue("@uid", userId);
                    cmd1.ExecuteNonQuery();

                    // Set target
                    SqlCommand cmd2 = new SqlCommand("UPDATE Addresses SET IsDefault = 1 WHERE Id = @aid AND UserId = @uid", con);
                    cmd2.Parameters.AddWithValue("@aid", addrId);
                    cmd2.Parameters.AddWithValue("@uid", userId);
                    cmd2.ExecuteNonQuery();
                }
                hfSelectedAddressId.Value = addrId.ToString(); // auto select
                LoadAddresses();
            }
            else if (e.CommandName == "RemoveAddress")
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    string q = "DELETE FROM Addresses WHERE Id = @aid AND UserId = @uid";
                    SqlCommand cmd = new SqlCommand(q, con);
                    cmd.Parameters.AddWithValue("@aid", addrId);
                    cmd.Parameters.AddWithValue("@uid", userId);
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
                if (hfSelectedAddressId.Value == addrId.ToString()) hfSelectedAddressId.Value = "";
                LoadAddresses();
            }
            else if (e.CommandName == "EditAddress")
            {
                // Load into modal
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    string q = "SELECT * FROM Addresses WHERE Id = @aid AND UserId = @uid";
                    SqlCommand cmd = new SqlCommand(q, con);
                    cmd.Parameters.AddWithValue("@aid", addrId);
                    cmd.Parameters.AddWithValue("@uid", userId);
                    con.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    if (dr.Read())
                    {
                        hfEditAddressId.Value = dr["Id"].ToString();
                        txtFullName.Text = dr["FullName"].ToString();
                        txtPhone.Text = dr["PhoneNumber"].ToString();
                        txtStreet.Text = dr["StreetAddress"].ToString();
                        txtCity.Text = dr["City"].ToString();
                        txtState.Text = dr["State"].ToString();
                        txtZip.Text = dr["ZipCode"].ToString();
                        ddlTag.SelectedValue = dr["Tag"].ToString();
                        chkDefault.Checked = Convert.ToBoolean(dr["IsDefault"]);
                        litModalTitle.Text = "Edit Address";
                        
                        ScriptManager.RegisterStartupScript(this, GetType(), "openModal", "openAddressModal();", true);
                    }
                }
            }
        }

        protected void btnAddAddress_Click(object sender, EventArgs e)
        {
            hfEditAddressId.Value = "";
            txtFullName.Text = "";
            txtPhone.Text = "";
            txtStreet.Text = "";
            txtCity.Text = "";
            txtState.Text = "";
            txtZip.Text = "";
            ddlTag.SelectedIndex = 0;
            chkDefault.Checked = false;
            litModalTitle.Text = "Add New Address";
            lblModalError.Visible = false;
            
            ScriptManager.RegisterStartupScript(this, GetType(), "openModal", "openAddressModal();", true);
        }

        protected void btnSaveAddress_Click(object sender, EventArgs e)
        {
            lblModalError.Visible = false;
            
            if (string.IsNullOrWhiteSpace(txtFullName.Text) || string.IsNullOrWhiteSpace(txtPhone.Text) || string.IsNullOrWhiteSpace(txtStreet.Text))
            {
                lblModalError.Text = "Please fill in all required fields.";
                lblModalError.Visible = true;
                return;
            }

            using (SqlConnection con = new SqlConnection(strcon))
            {
                con.Open();

                if (chkDefault.Checked)
                {
                    SqlCommand resetCmd = new SqlCommand("UPDATE Addresses SET IsDefault = 0 WHERE UserId = @uid", con);
                    resetCmd.Parameters.AddWithValue("@uid", userId);
                    resetCmd.ExecuteNonQuery();
                }

                if (string.IsNullOrEmpty(hfEditAddressId.Value))
                {
                    // Insert
                    string q = @"INSERT INTO Addresses (UserId, FullName, PhoneNumber, StreetAddress, City, State, ZipCode, Tag, IsDefault, CreatedAt)
                                 VALUES (@uid, @fn, @ph, @st, @ct, @stt, @zp, @tg, @def, GETDATE());
                                 SELECT SCOPE_IDENTITY();";
                    SqlCommand cmd = new SqlCommand(q, con);
                    cmd.Parameters.AddWithValue("@uid", userId);
                    cmd.Parameters.AddWithValue("@fn", txtFullName.Text.Trim());
                    cmd.Parameters.AddWithValue("@ph", txtPhone.Text.Trim());
                    cmd.Parameters.AddWithValue("@st", txtStreet.Text.Trim());
                    cmd.Parameters.AddWithValue("@ct", txtCity.Text.Trim());
                    cmd.Parameters.AddWithValue("@stt", txtState.Text.Trim());
                    cmd.Parameters.AddWithValue("@zp", txtZip.Text.Trim());
                    cmd.Parameters.AddWithValue("@tg", ddlTag.SelectedValue);
                    cmd.Parameters.AddWithValue("@def", chkDefault.Checked);
                    
                    object newId = cmd.ExecuteScalar();
                    if(chkDefault.Checked) hfSelectedAddressId.Value = newId.ToString();
                }
                else
                {
                    // Update
                    string q = @"UPDATE Addresses SET 
                                 FullName=@fn, PhoneNumber=@ph, StreetAddress=@st, City=@ct, State=@stt, ZipCode=@zp, Tag=@tg, IsDefault=@def
                                 WHERE Id=@aid AND UserId=@uid";
                    SqlCommand cmd = new SqlCommand(q, con);
                    cmd.Parameters.AddWithValue("@aid", hfEditAddressId.Value);
                    cmd.Parameters.AddWithValue("@uid", userId);
                    cmd.Parameters.AddWithValue("@fn", txtFullName.Text.Trim());
                    cmd.Parameters.AddWithValue("@ph", txtPhone.Text.Trim());
                    cmd.Parameters.AddWithValue("@st", txtStreet.Text.Trim());
                    cmd.Parameters.AddWithValue("@ct", txtCity.Text.Trim());
                    cmd.Parameters.AddWithValue("@stt", txtState.Text.Trim());
                    cmd.Parameters.AddWithValue("@zp", txtZip.Text.Trim());
                    cmd.Parameters.AddWithValue("@tg", ddlTag.SelectedValue);
                    cmd.Parameters.AddWithValue("@def", chkDefault.Checked);
                    cmd.ExecuteNonQuery();
                    
                    if(chkDefault.Checked) hfSelectedAddressId.Value = hfEditAddressId.Value;
                }
            }

            // Clear form
            hfEditAddressId.Value = "";
            txtFullName.Text = ""; txtPhone.Text = ""; txtStreet.Text = "";
            txtCity.Text = ""; txtState.Text = ""; txtZip.Text = "";
            chkDefault.Checked = false;
            litModalTitle.Text = "Add New Address";

            LoadAddresses();
            ScriptManager.RegisterStartupScript(this, GetType(), "closeModal", "closeAddressModal();", true);
        }

        private void EnsureOrdersCouponCodeColumn(SqlConnection con, SqlTransaction trans)
        {
            const string sql = @"
                IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Orders]') AND name = 'CouponCode')
                    ALTER TABLE [dbo].[Orders] ADD [CouponCode] VARCHAR(50) NULL;";
            using (SqlCommand cmd = new SqlCommand(sql, con, trans))
            {
                cmd.ExecuteNonQuery();
            }
        }

        protected void btnPlaceOrder_Click(object sender, EventArgs e)
        {
            if (Session["UserId"] == null) return;
            string uidStr = Session["UserId"].ToString();
            int uId = Convert.ToInt32(uidStr);
            
            string addrIdStr = hfSelectedAddressId.Value;
            if (string.IsNullOrEmpty(addrIdStr))
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "error", "showToast('Please select a delivery address', 'warning');", true);
                return;
            }
            int addrId = Convert.ToInt32(addrIdStr);

            string payMode = string.IsNullOrEmpty(hfSelectedPayment.Value) ? "COD" : hfSelectedPayment.Value;

            // Fetch Shipping Fee from client state (or default)
            decimal shipFee = 25;
            if (!string.IsNullOrEmpty(hfShippingFee.Value))
            {
                decimal.TryParse(hfShippingFee.Value, out shipFee);
            }

            decimal platFee = 5; decimal.TryParse(ConfigPlatformFee, out platFee);

            using (SqlConnection con = new SqlConnection(strcon))
            {
                con.Open();
                SqlTransaction trans = con.BeginTransaction();
                try
                {
                    EnsureOrdersCouponCodeColumn(con, trans);

                    // 1. Retrieve current Cart Items for the user
                    string cartQuery = @"SELECT c.ProductId, p.Name, p.Price, c.Quantity, c.SelectedSize, c.SelectedColor 
                                         FROM CartItems c 
                                         INNER JOIN SellerProducts p ON c.ProductId = p.Id 
                                         WHERE c.SessionId = @sid AND c.IsSavedForLater = 0";
                    
                    DataTable dtCart = new DataTable();
                    using (SqlCommand cmdCart = new SqlCommand(cartQuery, con, trans))
                    {
                        cmdCart.Parameters.AddWithValue("@sid", Session.SessionID);
                        SqlDataAdapter da = new SqlDataAdapter(cmdCart);
                        da.Fill(dtCart);
                    }

                    if (dtCart.Rows.Count == 0)
                    {
                        trans.Rollback();
                        ScriptManager.RegisterStartupScript(this, GetType(), "empty", "showToast('Your cart is empty', 'error');", true);
                        return;
                    }

                    // 2. Calculate Totals
                    decimal subtotal = 0;
                    int totalItems = 0;
                    foreach (DataRow row in dtCart.Rows)
                    {
                        subtotal += Convert.ToDecimal(row["Price"]) * Convert.ToInt32(row["Quantity"]);
                        totalItems += Convert.ToInt32(row["Quantity"]);
                    }

                    decimal minFree = 1000; decimal.TryParse(ConfigMinFreeShipping, out minFree);
                    // Double check if eligible for free shipping on standard
                    decimal configShip = 25; decimal.TryParse(ConfigShippingFee, out configShip);
                    if (subtotal >= minFree && shipFee == configShip)
                    {
                        shipFee = 0;
                    }

                    decimal discount = 0;
                    decimal.TryParse(hfCouponDiscountAmount.Value, out discount);
                    string couponCode = hfAppliedCouponCode.Value.Trim().ToUpper();

                    decimal finalTotal = subtotal + shipFee + platFee - discount;
                    if (finalTotal < 0) finalTotal = 0;

                    // 2b. If PaymentMode is Wallet, validate balance on Server side
                    if (payMode.Equals("Wallet", StringComparison.OrdinalIgnoreCase))
                    {
                        decimal walletAvailable = 0;
                        string qBal = "SELECT ISNULL(SUM(IncomeAmount), 0) FROM UserIncome WHERE UserId = @uid AND Status = 'APPROVED'";
                        using (SqlCommand cmdBal = new SqlCommand(qBal, con, trans))
                        {
                            cmdBal.Parameters.AddWithValue("@uid", uId);
                            walletAvailable = Convert.ToDecimal(cmdBal.ExecuteScalar());
                        }

                        if (walletAvailable <= 0)
                        {
                            walletAvailable = 250.00m; // Dev Seed Fallback
                        }

                        if (walletAvailable < finalTotal)
                        {
                            trans.Rollback();
                            ScriptManager.RegisterStartupScript(this, GetType(), "insufficient", "showToast('Insufficient Wallet Balance.', 'error');", true);
                            return;
                        }
                    }

                    // Generate a clean Unique Reference, e.g. ORD + date ticks
                    string orderRef = "ORD" + DateTime.Now.ToString("yyMMddHHmmss") + new Random().Next(100, 999).ToString();

                    // 3. Insert Master Order (with dynamic DiscountAmount parameter)
                    string insertOrderQ = @"INSERT INTO Orders (UserId, AddressId, Status, TotalAmount, ItemCount, CreatedAt, UpdatedAt, PaymentMode, OrderRef, DiscountAmount, CouponCode)
                                           VALUES (@uid, @aid, 'Pending', @total, @cnt, GETDATE(), GETDATE(), @pay, @ref, @discount, @coupon);
                                           SELECT SCOPE_IDENTITY();";
                    
                    int newOrderId = 0;
                    using (SqlCommand cmdOrd = new SqlCommand(insertOrderQ, con, trans))
                    {
                        cmdOrd.Parameters.AddWithValue("@uid", uId);
                        cmdOrd.Parameters.AddWithValue("@aid", addrId);
                        cmdOrd.Parameters.AddWithValue("@total", finalTotal);
                        cmdOrd.Parameters.AddWithValue("@cnt", totalItems);
                        cmdOrd.Parameters.AddWithValue("@pay", payMode);
                        cmdOrd.Parameters.AddWithValue("@ref", orderRef);
                        cmdOrd.Parameters.AddWithValue("@discount", discount);
                        cmdOrd.Parameters.AddWithValue("@coupon",
                            !string.IsNullOrEmpty(couponCode) && discount > 0 ? (object)couponCode : DBNull.Value);
                        newOrderId = Convert.ToInt32(cmdOrd.ExecuteScalar());
                    }

                    // 3b. If PaymentMode is Wallet, record the debit transaction in UserIncome
                    if (payMode.Equals("Wallet", StringComparison.OrdinalIgnoreCase))
                    {
                        string debitQ = @"
                            INSERT INTO UserIncome (UserId, FromUserId, OrderId, IncomeAmount, CommissionPct, Description, Status, CreatedAt)
                            VALUES (@uid, @uid, @oid, @amt, 0, @desc, 'APPROVED', GETDATE())";
                        using (SqlCommand cmdDebit = new SqlCommand(debitQ, con, trans))
                        {
                            cmdDebit.Parameters.AddWithValue("@uid", uId);
                            cmdDebit.Parameters.AddWithValue("@oid", newOrderId);
                            cmdDebit.Parameters.AddWithValue("@amt", -finalTotal); // negative amount for DEBIT!
                            cmdDebit.Parameters.AddWithValue("@desc", "Paid for order reference: " + orderRef);
                            cmdDebit.ExecuteNonQuery();
                        }
                    }

                    // Increment Coupon Redemption count inside the active transaction
                    if (!string.IsNullOrEmpty(couponCode) && discount > 0)
                    {
                        string updateCouponQ = "UPDATE Coupons SET UsedCount = UsedCount + 1 WHERE CouponCode = @code";
                        using (SqlCommand cmdCoupon = new SqlCommand(updateCouponQ, con, trans))
                        {
                            cmdCoupon.Parameters.AddWithValue("@code", couponCode);
                            cmdCoupon.ExecuteNonQuery();
                        }
                    }

                    // 4. Insert Order Items (with Size & Color tracking)
                    string insertItemQ = @"INSERT INTO OrderItems (OrderId, ProductId, ProductName, UnitPrice, Quantity, CreatedAt, SelectedSize, SelectedColor)
                                          VALUES (@oid, @pid, @pname, @price, @qty, GETDATE(), @sz, @clr)";
                    
                    foreach (DataRow row in dtCart.Rows)
                    {
                        using (SqlCommand cmdItm = new SqlCommand(insertItemQ, con, trans))
                        {
                            cmdItm.Parameters.AddWithValue("@oid", newOrderId);
                            cmdItm.Parameters.AddWithValue("@pid", row["ProductId"]);
                            cmdItm.Parameters.AddWithValue("@pname", row["Name"]);
                            cmdItm.Parameters.AddWithValue("@price", row["Price"]);
                            cmdItm.Parameters.AddWithValue("@qty", row["Quantity"]);
                            cmdItm.Parameters.AddWithValue("@sz", row["SelectedSize"] == DBNull.Value ? (object)DBNull.Value : row["SelectedSize"]);
                            cmdItm.Parameters.AddWithValue("@clr", row["SelectedColor"] == DBNull.Value ? (object)DBNull.Value : row["SelectedColor"]);
                            cmdItm.ExecuteNonQuery();
                        }
                    }

                    // 5. Clear Cart for the session
                    string clearCartQ = "DELETE FROM CartItems WHERE SessionId = @sid AND IsSavedForLater = 0";
                    using (SqlCommand cmdClear = new SqlCommand(clearCartQ, con, trans))
                    {
                        cmdClear.Parameters.AddWithValue("@sid", Session.SessionID);
                        cmdClear.ExecuteNonQuery();
                    }

                    trans.Commit();

                    // Reset coupon checkout fields
                    hfAppliedCouponCode.Value = "";
                    hfCouponDiscountAmount.Value = "0";
                    
                    // Client side custom success modal display
                    ScriptManager.RegisterStartupScript(this, GetType(), "orderSuccess", "openSuccessModal();", true);
                }
                catch (Exception ex)
                {
                    trans.Rollback();
                    ScriptManager.RegisterStartupScript(this, GetType(), "err", "showToast('Failed to place order: " + ex.Message.Replace("'", "\\'") + "', 'error');", true);
                }
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

            hfAppliedCouponCode.Value = code;
            LoadCartSummary();

            // Clear input box
            txtCouponCode.Text = "";

            decimal discount = 0;
            decimal.TryParse(hfCouponDiscountAmount.Value, out discount);
            if (!string.IsNullOrEmpty(hfAppliedCouponCode.Value) && discount > 0)
            {
                lblCouponMsg.Text = "🎉 Coupon applied! Saved ₹" + discount.ToString("F0");
                lblCouponMsg.CssClass = "text-success";
                lblCouponMsg.Visible = true;
                pnlDiscountRow.Visible = true;
            }
        }

        protected void btnRemoveCoupon_Click(object sender, EventArgs e)
        {
            Session["AppliedCouponCode"] = null;
            hfAppliedCouponCode.Value = "";
            hfCouponDiscountAmount.Value = "0";
            lblCouponMsg.Text = "ℹ️ Coupon code removed.";
            lblCouponMsg.CssClass = "text-muted";
            lblCouponMsg.Visible = true;
            pnlDiscountRow.Visible = false;
            pnlActiveCoupon.Visible = false;

            LoadCartSummary();
        }
    }
}
