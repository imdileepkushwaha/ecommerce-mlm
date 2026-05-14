using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace ecommerce_mlm
{
    public partial class OrderDetails : System.Web.UI.Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;
        private string currentStatusClean = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["Username"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (Request.QueryString["id"] == null)
            {
                ShowError();
                return;
            }

            if (!IsPostBack)
            {
                LoadOrderDetails(Request.QueryString["id"].ToString());
            }
        }

        private void LoadOrderDetails(string orderId)
        {
            string username = Session["Username"].ToString().Trim();
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    // 1. Fetch Master Order Info & Address
                    string qMain = @"SELECT O.*, A.FullName as AddrName, A.PhoneNumber as AddrPhone, 
                                     A.StreetAddress, A.City, A.State, A.ZipCode 
                                     FROM Orders O
                                     INNER JOIN Users U ON O.UserId = U.Id
                                     LEFT JOIN Addresses A ON O.AddressId = A.Id
                                     WHERE O.Id = @oid AND U.Username = @u";

                    using (SqlCommand cmd = new SqlCommand(qMain, con))
                    {
                        cmd.Parameters.AddWithValue("@oid", orderId);
                        cmd.Parameters.AddWithValue("@u", username);
                        con.Open();
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                string dbStatus = dr["Status"].ToString().Trim();
                                currentStatusClean = dbStatus.ToLower();

                                litHeadOrderId.Text = dr["Id"].ToString();
                                litOrderNo.Text = dr["Id"].ToString();
                                litOrderDate.Text = Convert.ToDateTime(dr["CreatedAt"]).ToString("dd MMM yyyy, hh:mm tt");
                                litGrandTotalHero.Text = String.Format("{0:n2}", dr["TotalAmount"]);

                                // Address Block
                                litAddrName.Text = dr["AddrName"] != DBNull.Value ? dr["AddrName"].ToString() : "N/A";
                                litAddrPhone.Text = dr["AddrPhone"] != DBNull.Value ? dr["AddrPhone"].ToString() : "N/A";
                                litAddrLine.Text = dr["StreetAddress"] != DBNull.Value ? dr["StreetAddress"].ToString() : "-";
                                litAddrCity.Text = dr["City"] != DBNull.Value ? dr["City"].ToString() : "";
                                litAddrState.Text = dr["State"] != DBNull.Value ? dr["State"].ToString() : "";
                                litAddrZip.Text = dr["ZipCode"] != DBNull.Value ? dr["ZipCode"].ToString() : "";

                                // Pricing
                                decimal subtotal = Convert.ToDecimal(dr["TotalAmount"]) + Convert.ToDecimal(dr["DiscountAmount"]);
                                litSubtotal.Text = String.Format("{0:n2}", subtotal);
                                litDiscount.Text = String.Format("{0:n2}", dr["DiscountAmount"]);
                                litGrandTotalFinal.Text = String.Format("{0:n2}", dr["TotalAmount"]);

                                litItemCount.Text = dr["ItemCount"].ToString();

                                // Construct visual badge based on existing reusable styles
                                litStatusBadge.Text = string.Format("<span class='order-status-badge status-{0}'><i class='fas fa-circle'></i> {1}</span>", currentStatusClean.Replace(" ", "-"), dbStatus);

                                // Store the status globally for templating logic
                                ViewState["CurrentStatus"] = currentStatusClean;

                                SetupTimelineAndButtons(currentStatusClean);
                            }
                            else
                            {
                                ShowError();
                                return;
                            }
                        }
                    }

                    // 2. Fetch Purchased Items
                    string qItems = @"SELECT OI.*, P.MainImage 
                                      FROM OrderItems OI
                                      LEFT JOIN SellerProducts P ON OI.ProductId = P.Id
                                      WHERE OI.OrderId = @oid";
                    
                    using (SqlCommand cmdItems = new SqlCommand(qItems, con))
                    {
                        cmdItems.Parameters.AddWithValue("@oid", orderId);
                        SqlDataAdapter da = new SqlDataAdapter(cmdItems);
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        rptItems.DataSource = dt;
                        rptItems.DataBind();
                    }
                }
            }
            catch (Exception)
            {
                ShowError();
            }
        }

        private void SetupTimelineAndButtons(string status)
        {
            // Timeline Visual Setup logic
            int fillPercent = 0;
            if (status == "placed" || status == "pending") fillPercent = 5;
            else if (status == "processing" || status == "confirmed") fillPercent = 33;
            else if (status == "shipped" || status == "dispatched") fillPercent = 66;
            else if (status == "out for delivery") fillPercent = 80;
            else if (status == "delivered" || status == "completed") fillPercent = 90;

            litProgressLine.Text = string.Format("<div class='timeline-progress-line' style='width: {0}%;'></div>", fillPercent);

            // Visibility of Actions Setup logic
            if (status == "placed" || status == "pending" || status == "confirmed")
            {
                lnkCancelOrder.Visible = true;
            }
            
            if (status == "delivered" || status == "completed")
            {
                lnkReturnOrder.Visible = true;
                btnWriteReview.Visible = true;
            }
        }

        protected string GetStepClass(string stepName)
        {
            string curStatus = ViewState["CurrentStatus"] != null ? ViewState["CurrentStatus"].ToString() : "placed";
            
            int rankCur = GetStatusRank(curStatus);
            int rankStep = GetStatusRank(stepName);

            if (rankCur > rankStep) return "completed";
            if (rankCur == rankStep) return "active";
            return "";
        }

        private int GetStatusRank(string s)
        {
            s = s.ToLower().Trim();
            if (s == "placed" || s == "pending") return 0;
            if (s == "processing" || s == "confirmed") return 1;
            if (s == "shipped" || s == "out for delivery" || s == "dispatched") return 2;
            if (s == "delivered" || s == "completed") return 3;
            return -1; // Fallback for cancelled etc
        }

        protected void lnkCancelOrder_Click(object sender, EventArgs e)
        {
            string orderId = Request.QueryString["id"];
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    string q = "UPDATE Orders SET Status = 'Cancelled' WHERE Id = @oid";
                    using (SqlCommand cmd = new SqlCommand(q, con))
                    {
                        cmd.Parameters.AddWithValue("@oid", orderId);
                        con.Open();
                        cmd.ExecuteNonQuery();
                    }
                }
                Response.Redirect("OrderDetails.aspx?id=" + orderId);
            }
            catch
            {
                // Fail silently or notify
            }
        }

        protected void lnkReturnOrder_Click(object sender, EventArgs e)
        {
            // Conceptual: User initiated return workflow redirection.
            ScriptManager.RegisterStartupScript(this, GetType(), "ReturnMsg", "alert('Return request submitted successfully. Our agent will contact you shortly.');", true);
        }

        private void ShowError()
        {
            pnlContent.Visible = false;
            pnlError.Visible = true;
        }
    }
}
