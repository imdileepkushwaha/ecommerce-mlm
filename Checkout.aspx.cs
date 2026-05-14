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
                LoadAddresses();
                LoadCartSummary();
                litEstDate.Text = DateTime.Now.AddDays(3).ToString("dd MMM yyyy") + " - " + DateTime.Now.AddDays(5).ToString("dd MMM yyyy");
            }
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
            decimal finalTotal = _subtotal + shipping + platFee;

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
                    // 1. Retrieve current Cart Items for the user
                    string cartQuery = @"SELECT c.ProductId, p.Name, p.Price, c.Quantity 
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

                    decimal finalTotal = subtotal + shipFee + platFee;

                    // Generate a clean Unique Reference, e.g. ORD + date ticks
                    string orderRef = "ORD" + DateTime.Now.ToString("yyMMddHHmmss") + new Random().Next(100, 999).ToString();

                    // 3. Insert Master Order
                    string insertOrderQ = @"INSERT INTO Orders (UserId, AddressId, Status, TotalAmount, ItemCount, CreatedAt, UpdatedAt, PaymentMode, OrderRef, DiscountAmount)
                                           VALUES (@uid, @aid, 'Pending', @total, @cnt, GETDATE(), GETDATE(), @pay, @ref, 0);
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
                        newOrderId = Convert.ToInt32(cmdOrd.ExecuteScalar());
                    }

                    // 4. Insert Order Items
                    string insertItemQ = @"INSERT INTO OrderItems (OrderId, ProductId, ProductName, UnitPrice, Quantity, CreatedAt)
                                          VALUES (@oid, @pid, @pname, @price, @qty, GETDATE())";
                    
                    foreach (DataRow row in dtCart.Rows)
                    {
                        using (SqlCommand cmdItm = new SqlCommand(insertItemQ, con, trans))
                        {
                            cmdItm.Parameters.AddWithValue("@oid", newOrderId);
                            cmdItm.Parameters.AddWithValue("@pid", row["ProductId"]);
                            cmdItm.Parameters.AddWithValue("@pname", row["Name"]);
                            cmdItm.Parameters.AddWithValue("@price", row["Price"]);
                            cmdItm.Parameters.AddWithValue("@qty", row["Quantity"]);
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
    }
}
