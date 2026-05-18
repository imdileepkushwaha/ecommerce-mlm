using System;
using System.Web;
using System.Web.UI;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace EcommerceWebsite
{
    public partial class SellerMaster : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Safe auto-login for local development / browser testing
            string host = Request.Url.Host.ToLower();
            if (Session["SellerId"] == null && (host == "localhost" || host == "127.0.0.1" || host == "::1" || Request.IsLocal))
            {
                Session["SellerId"] = "1";
                Session["SellerName"] = "Super Admin";
                Session["SellerEmail"] = "admin@merchant-portal.com";
            }

            // Security Gate: Pre-verify merchant session integrity
            if (Session["SellerId"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!EnsureSellerSessionStillValid())
            {
                return;
            }

            if (!IsPostBack)
            {
                // Dynamically Bind global Header variables
                string name = Session["SellerName"] != null ? Session["SellerName"].ToString() : "Merchant";
                litWelcomeName.Text = name;
                litDropdownName.Text = name;
                litAvatarLetter.Text = string.IsNullOrEmpty(name) ? "M" : name.Substring(0, 1).ToUpper();
                litSellerEmail.Text = Session["SellerEmail"] != null ? Session["SellerEmail"].ToString() : "";

                int sid = Convert.ToInt32(Session["SellerId"]);
                LoadNotifications(sid);
            }
        }

        private bool EnsureSellerSessionStillValid()
        {
            int sid;
            if (!int.TryParse(Session["SellerId"].ToString(), out sid))
            {
                ClearSellerSession();
                Response.Redirect("Login.aspx?blocked=1");
                return false;
            }

            try
            {
                string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT IsActive, ISNULL(DeletionStatus, 'None') AS DeletionStatus FROM SellerUsers WHERE Id = @id", con))
                    {
                        cmd.Parameters.AddWithValue("@id", sid);
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (!dr.Read())
                            {
                                ClearSellerSession();
                                Response.Redirect("Login.aspx?blocked=1");
                                return false;
                            }

                            string del = dr["DeletionStatus"] != DBNull.Value ? dr["DeletionStatus"].ToString().Trim() : "None";
                            if (del.Equals("Approved", StringComparison.OrdinalIgnoreCase) ||
                                del.Equals("Pending", StringComparison.OrdinalIgnoreCase))
                            {
                                ClearSellerSession();
                                Response.Redirect("Login.aspx?blocked=1");
                                return false;
                            }

                            bool active = dr["IsActive"] != DBNull.Value && Convert.ToBoolean(dr["IsActive"]);
                            if (!active)
                            {
                                ClearSellerSession();
                                Response.Redirect("Login.aspx?blocked=1");
                                return false;
                            }
                        }
                    }
                }
            }
            catch
            {
                ClearSellerSession();
                Response.Redirect("Login.aspx?blocked=1");
                return false;
            }

            return true;
        }

        private void ClearSellerSession()
        {
            Session.Remove("SellerId");
            Session.Remove("SellerName");
            Session.Remove("SellerEmail");
        }

        private void LoadNotifications(int sid)
        {
            try
            {
                string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    
                    StringBuilder sb = new StringBuilder();
                    int totalAlerts = 0;
                    string kycStatus = "";
                    int lowStockCount = 0;
                    int outOfStockCount = 0;
                    int pendingOrders = 0;

                    using (SqlCommand cmd = new SqlCommand("sp_Seller_GetNotificationSummary", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.CommandTimeout = 30;
                        cmd.Parameters.AddWithValue("@SellerId", sid);
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                kycStatus = dr["KycStatus"] != DBNull.Value ? dr["KycStatus"].ToString() : "";
                                lowStockCount = dr["LowStockCount"] != DBNull.Value ? Convert.ToInt32(dr["LowStockCount"]) : 0;
                                outOfStockCount = dr["OutOfStockCount"] != DBNull.Value ? Convert.ToInt32(dr["OutOfStockCount"]) : 0;
                                pendingOrders = dr["PendingOrdersCount"] != DBNull.Value ? Convert.ToInt32(dr["PendingOrdersCount"]) : 0;
                            }
                        }
                    }

                    if (kycStatus == "Approved")
                    {
                        sb.Append(@"
                            <div class='notif-item' onclick=""window.location='Kyc.aspx'"">
                                <i class='fas fa-circle-check notif-item-icon success'></i>
                                <div class='notif-item-content'>
                                    <p>KYC Portfolio verified successfully.</p>
                                    <span>Verified</span>
                                </div>
                            </div>");
                    }
                    else if (kycStatus == "Pending")
                    {
                        totalAlerts++;
                        sb.Append(@"
                            <div class='notif-item unread' onclick=""window.location='Kyc.aspx'"">
                                <i class='fas fa-circle-exclamation notif-item-icon warning'></i>
                                <div class='notif-item-content'>
                                    <p>KYC Portfolio under audit review.</p>
                                    <span>Pending approval</span>
                                </div>
                            </div>");
                    }
                    else // Rejected or Not Uploaded / Empty
                    {
                        totalAlerts++;
                        sb.Append(@"
                            <div class='notif-item unread' onclick=""window.location='Kyc.aspx'"">
                                <i class='fas fa-circle-exclamation notif-item-icon warning' style='color:#ef4444;'></i>
                                <div class='notif-item-content'>
                                    <p>KYC identity verification required.</p>
                                    <span>Action required</span>
                                </div>
                            </div>");
                    }

                    if (lowStockCount > 0)
                    {
                        totalAlerts++;
                        sb.AppendFormat(@"
                            <div class='notif-item unread' onclick=""window.location='Inventory.aspx'"">
                                <i class='fas fa-triangle-exclamation notif-item-icon warning'></i>
                                <div class='notif-item-content'>
                                    <p>{0} products running low on stock.</p>
                                    <span>Restock items soon</span>
                                </div>
                            </div>", lowStockCount);
                    }

                    if (outOfStockCount > 0)
                    {
                        totalAlerts++;
                        sb.AppendFormat(@"
                            <div class='notif-item unread' onclick=""window.location='Inventory.aspx'"">
                                <i class='fas fa-circle-xmark notif-item-icon warning' style='color:#ef4444;'></i>
                                <div class='notif-item-content'>
                                    <p>{0} products completely sold out.</p>
                                    <span>Out of stock</span>
                                </div>
                            </div>", outOfStockCount);
                    }

                    if (pendingOrders > 0)
                    {
                        totalAlerts++;
                        sb.AppendFormat(@"
                            <div class='notif-item unread' onclick=""window.location='Orders.aspx'"">
                                <i class='fas fa-box notif-item-icon info'></i>
                                <div class='notif-item-content'>
                                    <p>{0} new pending orders to fulfill.</p>
                                    <span>Fulfill package</span>
                                </div>
                            </div>", pendingOrders);
                    }

                    // If absolutely no warnings/alerts, add a premium default state item
                    if (sb.Length == 0 || totalAlerts == 0)
                    {
                        sb.Append(@"
                            <div style='padding: 24px 14px; text-align: center; color: #94a3b8; font-size: 0.8rem;'>
                                <i class='far fa-bell-slash' style='font-size: 1.5rem; margin-bottom: 8px; display: block; color: #cbd5e1;'></i>
                                No active alerts detected.
                            </div>");
                        bellDot.Visible = false;
                    }
                    else
                    {
                        bellDot.Visible = true;
                    }

                    litNotifList.Text = sb.ToString();
                }
            }
            catch
            {
                litNotifList.Text = @"
                    <div style='padding: 20px; text-align: center; color: #ef4444; font-size: 0.75rem;'>
                        Error loading alert feed.
                    </div>";
                bellDot.Visible = false;
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            // Purge Session Vectors
            Session.Remove("SellerId");
            Session.Remove("SellerName");
            Session.Remove("SellerEmail");
            
            Response.Redirect("Login.aspx");
        }
    }
}
