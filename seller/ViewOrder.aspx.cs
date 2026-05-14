using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace EcommerceWebsite
{
    public partial class SellerViewOrder : System.Web.UI.Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["SellerId"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (string.IsNullOrEmpty(Request.QueryString["id"]))
            {
                Response.Redirect("Orders.aspx");
                return;
            }

            if (!IsPostBack)
            {
                int orderId = 0;
                if (int.TryParse(Request.QueryString["id"], out orderId))
                {
                    LoadOrderDetail(orderId);
                }
                else
                {
                    Response.Redirect("Orders.aspx");
                }
            }
        }

        private void LoadOrderDetail(int oId)
        {
            int sellerId = Convert.ToInt32(Session["SellerId"]);

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();

                    // 1. Load Master Order Info and Customer Details securely
                    string orderSql = @"
                        SELECT o.*, 
                               a.FullName as AddrFullName, a.PhoneNumber, a.StreetAddress, a.City, a.State, a.ZipCode, a.Tag,
                               u.Email as CustEmail, u.FullName as CustFullName
                        FROM Orders o
                        LEFT JOIN Addresses a ON o.AddressId = a.Id
                        LEFT JOIN Users u ON o.UserId = u.Id
                        WHERE o.Id = @OrderId";

                    using (SqlCommand cmd = new SqlCommand(orderSql, con))
                    {
                        cmd.Parameters.AddWithValue("@OrderId", oId);
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            DataRow row = dt.Rows[0];
                            string status = row["Status"] != DBNull.Value ? row["Status"].ToString().Trim() : "Pending";
                            
                            litOrderRef.Text = row["OrderRef"] != DBNull.Value ? row["OrderRef"].ToString() : "N/A";
                            litOrderDate.Text = Convert.ToDateTime(row["CreatedAt"]).ToString("yyyy-MM-dd HH:mm:ss");
                            litPaymentMode.Text = row["PaymentMode"] != DBNull.Value ? row["PaymentMode"].ToString().ToUpper() : "COD";
                            litOrderTotal.Text = "Rs " + Convert.ToDecimal(row["TotalAmount"]).ToString("N0");

                            // Summary Literals
                            litSumStatus.Text = status;
                            litCustName.Text = row["CustFullName"] != DBNull.Value ? row["CustFullName"].ToString() : "Guest User";
                            litCustEmail.Text = row["CustEmail"] != DBNull.Value ? row["CustEmail"].ToString() : "noemail@yopmail.com";

                            // Addresses display
                            string shippingInfo = string.Format("{0} · {1} · {2}, {3} {4} · Ph: {5}",
                                row["AddrFullName"] != DBNull.Value ? row["AddrFullName"].ToString() : "Guest",
                                row["StreetAddress"] != DBNull.Value ? row["StreetAddress"].ToString() : "",
                                row["City"] != DBNull.Value ? row["City"].ToString() : "",
                                row["State"] != DBNull.Value ? row["State"].ToString() : "",
                                row["ZipCode"] != DBNull.Value ? row["ZipCode"].ToString() : "",
                                row["PhoneNumber"] != DBNull.Value ? row["PhoneNumber"].ToString() : ""
                            );
                            litShippingAddress.Text = shippingInfo;
                            litDeliveryAddress.Text = shippingInfo;

                            // Track dates
                            DateTime placedDt = Convert.ToDateTime(row["CreatedAt"]);
                            DateTime updatedDt = row["UpdatedAt"] != DBNull.Value ? Convert.ToDateTime(row["UpdatedAt"]) : placedDt;
                            litPlacedDateFormatted.Text = placedDt.ToString("MMMM dd, yyyy · h:mm tt");

                            // Load Stepper State
                            LoadStepper(status, placedDt, updatedDt);

                            // Handle "Action Status Banner" logic dynamically across ALL lifecycle steps
                            string targetStatus = "";
                            string btnText = "";
                            
                            if (status.Equals("Pending", StringComparison.OrdinalIgnoreCase) ||
                                status.Equals("Placed", StringComparison.OrdinalIgnoreCase) ||
                                status.Equals("Processing", StringComparison.OrdinalIgnoreCase))
                            {
                                targetStatus = "Confirmed";
                                btnText = "Confirm Order";
                            }
                            else if (status.Equals("Confirmed", StringComparison.OrdinalIgnoreCase))
                            {
                                targetStatus = "Shipped";
                                btnText = "Mark as Shipped";
                            }
                            else if (status.Equals("Shipped", StringComparison.OrdinalIgnoreCase) || status.Equals("Dispatched", StringComparison.OrdinalIgnoreCase))
                            {
                                targetStatus = "Out for delivery";
                                btnText = "Mark as Out for Delivery";
                            }
                            else if (status.Equals("Out for delivery", StringComparison.OrdinalIgnoreCase))
                            {
                                targetStatus = "Delivered";
                                btnText = "Confirm Delivery";
                            }
                            else if (status.Equals("Return requested", StringComparison.OrdinalIgnoreCase))
                            {
                                targetStatus = "Return Approved";
                                btnText = "Approve Return Request";
                            }
                            else if (status.Equals("Return Approved", StringComparison.OrdinalIgnoreCase) || status.Equals("Return Processing", StringComparison.OrdinalIgnoreCase))
                            {
                                targetStatus = "Refunded";
                                btnText = "Complete Refund & Close";
                            }

                            if (!string.IsNullOrEmpty(targetStatus))
                            {
                                pnlActionBox.Visible = true;
                                litFlowSource.Text = status;
                                litFlowTarget.Text = targetStatus;
                                btnConfirmOrder.Text = "<i class='fas fa-arrow-right'></i> " + btnText;
                                btnConfirmOrder.CommandArgument = targetStatus;

                                // Assign dynamic button stage colors
                                string clr = "od-btn-confirmed";
                                if (targetStatus.Equals("Shipped", StringComparison.OrdinalIgnoreCase)) clr = "od-btn-shipped";
                                else if (targetStatus.Equals("Out for delivery", StringComparison.OrdinalIgnoreCase)) clr = "od-btn-outfordelivery";
                                else if (targetStatus.Equals("Delivered", StringComparison.OrdinalIgnoreCase)) clr = "od-btn-delivered";
                                else if (targetStatus.ToLower().Contains("return") || targetStatus.Equals("Refunded", StringComparison.OrdinalIgnoreCase)) clr = "od-btn-return";

                                btnConfirmOrder.CssClass = "od-btn-action " + clr;
                            }
                            else
                            {
                                pnlActionBox.Visible = false;
                            }
                        }
                        else
                        {
                            Response.Redirect("Orders.aspx");
                            return;
                        }
                    }

                    // 2. Load Items belonging to this seller
                    string itemsSql = @"
                        SELECT oi.*, p.MainImage, p.Slug, ISNULL(p.Category, 'General') as Category, ISNULL(p.ColorName, '--') as ColorName, ISNULL(p.ColorCode, '') as ColorCode, o.Status as OrderStatus
                        FROM OrderItems oi
                        JOIN SellerProducts p ON oi.ProductId = p.Id
                        JOIN Orders o ON oi.OrderId = o.Id
                        WHERE oi.OrderId = @OrderId AND p.SellerId = @SellerId";

                    using (SqlCommand cmdItems = new SqlCommand(itemsSql, con))
                    {
                        cmdItems.Parameters.AddWithValue("@OrderId", oId);
                        cmdItems.Parameters.AddWithValue("@SellerId", sellerId);
                        SqlDataAdapter daItems = new SqlDataAdapter(cmdItems);
                        DataTable dtItems = new DataTable();
                        daItems.Fill(dtItems);

                        if (dtItems.Rows.Count > 0)
                        {
                            rptOrderItems.DataSource = dtItems;
                            rptOrderItems.DataBind();

                            decimal sellerSubtotal = 0;
                            foreach (DataRow r in dtItems.Rows)
                            {
                                int q = Convert.ToInt32(r["Quantity"]);
                                decimal p = Convert.ToDecimal(r["UnitPrice"]);
                                sellerSubtotal += (q * p);
                            }
                            litSellerItemsTotal.Text = "Rs " + sellerSubtotal.ToString("N0");
                        }
                        else
                        {
                            Response.Redirect("Orders.aspx");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Response.Write("<script>console.error('Data Bind Failure: " + ex.Message + "');</script>");
            }
        }

        private void LoadStepper(string status, DateTime placedDate, DateTime updatedDate)
        {
            string fmt = "MMM dd, yyyy · h:mm tt";
            litStepDate1.Text = placedDate.ToString(fmt);
            litStepDate2.Text = "--";
            litStepDate3.Text = "--";
            litStepDate4.Text = "--";
            litStepDate5.Text = "--";

            clsTrack1.Text = "od-step-track"; clsCap1.Text = "od-cap-lbl";
            clsTrack2.Text = "od-step-track"; clsCap2.Text = "od-cap-lbl";
            clsTrack3.Text = "od-step-track"; clsCap3.Text = "od-cap-lbl";
            clsTrack4.Text = "od-step-track"; clsCap4.Text = "od-cap-lbl";
            clsTrack5.Text = "od-step-track"; clsCap5.Text = "od-cap-lbl";

            // Special dynamic override for Return Workflows
            if (status.ToLower().Contains("return") || status.Equals("Refunded", StringComparison.OrdinalIgnoreCase))
            {
                litCapName1.Text = "Return Req";
                litCapName2.Text = "Approved";
                litCapName3.Text = "Picked Up";
                litCapName4.Text = "Received";
                litCapName5.Text = "Refunded";

                if (status.Equals("Refunded", StringComparison.OrdinalIgnoreCase) || status.Equals("Return Completed", StringComparison.OrdinalIgnoreCase))
                {
                    clsTrack1.Text = "od-step-track completed"; clsCap1.Text = "od-cap-lbl done";
                    clsTrack2.Text = "od-step-track completed"; clsCap2.Text = "od-cap-lbl done";
                    clsTrack3.Text = "od-step-track completed"; clsCap3.Text = "od-cap-lbl done";
                    clsTrack4.Text = "od-step-track completed"; clsCap4.Text = "od-cap-lbl done";
                    clsTrack5.Text = "od-step-track completed"; clsCap5.Text = "od-cap-lbl done";
                    litCurrentStage.Text = "Refund Closed";
                    litEta.Text = "Return sequence completed";
                    
                    litStepDate2.Text = placedDate.AddDays(1).ToString(fmt);
                    litStepDate3.Text = placedDate.AddDays(2).ToString(fmt);
                    litStepDate4.Text = placedDate.AddDays(3).ToString(fmt);
                    litStepDate5.Text = updatedDate.ToString(fmt);
                }
                else if (status.Equals("Return Approved", StringComparison.OrdinalIgnoreCase) || status.Equals("Return Processing", StringComparison.OrdinalIgnoreCase))
                {
                    clsTrack1.Text = "od-step-track completed"; clsCap1.Text = "od-cap-lbl done";
                    clsTrack2.Text = "od-step-track completed"; clsCap2.Text = "od-cap-lbl done";
                    clsTrack3.Text = "od-step-track active";    clsCap3.Text = "od-cap-lbl active";
                    litCurrentStage.Text = "Return Approved";
                    litEta.Text = "Awaiting collection";
                    
                    litStepDate2.Text = updatedDate.ToString(fmt);
                }
                else // Return requested
                {
                    clsTrack1.Text = "od-step-track active"; clsCap1.Text = "od-cap-lbl active";
                    litCurrentStage.Text = "Return Requested";
                    litEta.Text = "Awaiting seller approval";
                }
                return;
            }

            if (status.Equals("Delivered", StringComparison.OrdinalIgnoreCase))
            {
                clsTrack1.Text = "od-step-track completed"; clsCap1.Text = "od-cap-lbl done";
                clsTrack2.Text = "od-step-track completed"; clsCap2.Text = "od-cap-lbl done";
                clsTrack3.Text = "od-step-track completed"; clsCap3.Text = "od-cap-lbl done";
                clsTrack4.Text = "od-step-track completed"; clsCap4.Text = "od-cap-lbl done";
                clsTrack5.Text = "od-step-track completed"; clsCap5.Text = "od-cap-lbl done";
                litCurrentStage.Text = "Delivered";
                litEta.Text = "Delivered Successfully";

                litStepDate2.Text = placedDate.AddMinutes(30).ToString(fmt);
                litStepDate3.Text = placedDate.AddHours(2).ToString(fmt);
                litStepDate4.Text = placedDate.AddHours(5).ToString(fmt);
                litStepDate5.Text = updatedDate.ToString(fmt);
            }
            else if (status.Equals("Out for delivery", StringComparison.OrdinalIgnoreCase))
            {
                clsTrack1.Text = "od-step-track completed"; clsCap1.Text = "od-cap-lbl done";
                clsTrack2.Text = "od-step-track completed"; clsCap2.Text = "od-cap-lbl done";
                clsTrack3.Text = "od-step-track completed"; clsCap3.Text = "od-cap-lbl done";
                clsTrack4.Text = "od-step-track active";    clsCap4.Text = "od-cap-lbl active";
                litCurrentStage.Text = "Out for delivery";
                litEta.Text = "Expected today";

                litStepDate2.Text = placedDate.AddMinutes(30).ToString(fmt);
                litStepDate3.Text = placedDate.AddHours(2).ToString(fmt);
                litStepDate4.Text = updatedDate.ToString(fmt);
            }
            else if (status.Equals("Shipped", StringComparison.OrdinalIgnoreCase) || status.Equals("Dispatched", StringComparison.OrdinalIgnoreCase))
            {
                clsTrack1.Text = "od-step-track completed"; clsCap1.Text = "od-cap-lbl done";
                clsTrack2.Text = "od-step-track completed"; clsCap2.Text = "od-cap-lbl done";
                clsTrack3.Text = "od-step-track active";    clsCap3.Text = "od-cap-lbl active";
                litCurrentStage.Text = "Shipped";
                litEta.Text = "Expected in 2-3 days";

                litStepDate2.Text = placedDate.AddMinutes(30).ToString(fmt);
                litStepDate3.Text = updatedDate.ToString(fmt);
            }
            else if (status.Equals("Confirmed", StringComparison.OrdinalIgnoreCase))
            {
                clsTrack1.Text = "od-step-track completed"; clsCap1.Text = "od-cap-lbl done";
                clsTrack2.Text = "od-step-track active";    clsCap2.Text = "od-cap-lbl active";
                litCurrentStage.Text = "Order Confirmed";
                litEta.Text = "Preparing for dispatch";

                litStepDate2.Text = updatedDate.ToString(fmt);
            }
            else // Pending / Placed / Processing
            {
                clsTrack1.Text = "od-step-track active"; clsCap1.Text = "od-cap-lbl active";
                litCurrentStage.Text = "Preparing order";
                litEta.Text = "Expected by " + placedDate.AddDays(5).ToString("MMMM dd");
            }
        }

        protected void btnConfirmOrder_Click(object sender, EventArgs e)
        {
            int orderId = Convert.ToInt32(Request.QueryString["id"]);
            string nextStatus = btnConfirmOrder.CommandArgument;

            if (string.IsNullOrEmpty(nextStatus)) return;

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string updateSql = "UPDATE Orders SET Status = @Status, UpdatedAt = GETDATE() WHERE Id = @OrderId";
                    using (SqlCommand cmd = new SqlCommand(updateSql, con))
                    {
                        cmd.Parameters.AddWithValue("@Status", nextStatus);
                        cmd.Parameters.AddWithValue("@OrderId", orderId);
                        cmd.ExecuteNonQuery();
                    }
                }
                // Reload fresh details
                LoadOrderDetail(orderId);
            }
            catch (Exception ex)
            {
                Response.Write("<script>alert('Confirmation failure: " + ex.Message + "');</script>");
            }
        }

        protected string GetItemImage(object dbImage)
        {
            string path = dbImage != DBNull.Value && !string.IsNullOrEmpty(dbImage.ToString()) ? dbImage.ToString() : "";
            if (!string.IsNullOrEmpty(path))
            {
                if (path.StartsWith("http://", StringComparison.OrdinalIgnoreCase) || 
                    path.StartsWith("https://", StringComparison.OrdinalIgnoreCase) || 
                    path.StartsWith("//"))
                {
                    return string.Format("<img src='{0}' alt='item' />", path);
                }
                string clean = path.StartsWith("~") ? path.Substring(1) : path;
                if (!clean.StartsWith("/")) clean = "/" + clean;
                return string.Format("<img src='{0}' alt='item' />", clean);
            }
            return "<i class='fas fa-image' style='color:#cbd5e1;'></i>";
        }

        protected string GetOrderBadgeSmall(object statusObj)
        {
            string status = statusObj != DBNull.Value ? statusObj.ToString().Trim() : "Pending";
            string colorClass = "ord-pill-status";

            if (status.Equals("Delivered", StringComparison.OrdinalIgnoreCase))
                colorClass += " ord-status-delivered";
            else if (status.Equals("Shipped", StringComparison.OrdinalIgnoreCase) || status.Equals("Dispatched", StringComparison.OrdinalIgnoreCase))
                colorClass += " ord-status-shipped";
            else if (status.Equals("Cancelled", StringComparison.OrdinalIgnoreCase) || status.Equals("Rejected", StringComparison.OrdinalIgnoreCase))
                colorClass += " ord-status-cancelled";
            else
                colorClass += " ord-status-processing";

            return string.Format("<span class='{0}'>{1}</span>", colorClass, status);
        }
    }
}
