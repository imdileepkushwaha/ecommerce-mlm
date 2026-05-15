using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace EcommerceWebsite
{
    public partial class SellerOrders : System.Web.UI.Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["SellerId"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                BindKPIs();
                BindOrders();
            }
        }

        private void BindKPIs()
        {
            int sellerId = Convert.ToInt32(Session["SellerId"]);
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    // Execute specialized analytics aggregator SP for low latency performance
                    using (SqlCommand cmd = new SqlCommand("sp_Seller_GetOrderMetrics", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@SellerId", sellerId);
                        cmd.Parameters.AddWithValue("@DateFilter", ddlDateFilter.SelectedValue);
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                litAllOrders.Text = dr["TotalOrders"] != DBNull.Value ? dr["TotalOrders"].ToString() : "0";
                                litNeedsConfirm.Text = dr["NeedsConfirm"] != DBNull.Value ? dr["NeedsConfirm"].ToString() : "0";
                                litInTransit.Text = dr["InTransit"] != DBNull.Value ? dr["InTransit"].ToString() : "0";
                                litDelivered.Text = dr["Delivered"] != DBNull.Value ? dr["Delivered"].ToString() : "0";
                                
                                litReturnRequests.Text = dr["ReturnRequests"] != DBNull.Value ? dr["ReturnRequests"].ToString() : "0";
                                litOpenReturns.Text = "0"; 
                                litReturnCompleted.Text = "0"; 
                                litCancelledReturn.Text = "0";
                            }
                        }
                    }
                }
            }
            catch
            {
                litAllOrders.Text = "0";
                litNeedsConfirm.Text = "0";
                litInTransit.Text = "0";
                litDelivered.Text = "0";
                litReturnRequests.Text = "0";
                litOpenReturns.Text = "0"; 
                litReturnCompleted.Text = "0"; 
                litCancelledReturn.Text = "0";
            }
        }

        private void BindOrders()
        {
            int sellerId = Convert.ToInt32(Session["SellerId"]);
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    // Routing dataset population via cached optimized stored execution tree
                    using (SqlCommand cmd = new SqlCommand("sp_Seller_GetOrdersList", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@SellerId", sellerId);
                        cmd.Parameters.AddWithValue("@DateFilter", ddlDateFilter.SelectedValue);
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        int totalCount = dt.Rows.Count;
                        litFooterCount.Text = totalCount.ToString();
                        litFooterCount2.Text = totalCount.ToString();
                        litHeaderTotal.Text = totalCount.ToString() + " orders total. Auto-refresh keeps the list current.";

                        if (totalCount > 0)
                        {
                            rptOrders.DataSource = dt;
                            rptOrders.DataBind();
                            rptOrders.Visible = true;
                            phEmptyOrders.Visible = false;
                        }
                        else
                        {
                            rptOrders.DataSource = null;
                            rptOrders.DataBind();
                            rptOrders.Visible = false;
                            phEmptyOrders.Visible = true;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Response.Write("<script>console.error('SQL stream error: " + ex.Message + "');</script>");
            }
        }

        protected string GetOrderBadgeRedesign(object statusObj)
        {
            string status = statusObj != DBNull.Value ? statusObj.ToString().Trim() : "Pending";
            string statusClass = "ord-pill-status";

            if (status.Equals("Delivered", StringComparison.OrdinalIgnoreCase))
            {
                statusClass += " ord-status-delivered";
            }
            else if (status.Equals("Shipped", StringComparison.OrdinalIgnoreCase) || status.Equals("Dispatched", StringComparison.OrdinalIgnoreCase) || status.Equals("In Transit", StringComparison.OrdinalIgnoreCase))
            {
                statusClass += " ord-status-shipped";
            }
            else if (status.Equals("Cancelled", StringComparison.OrdinalIgnoreCase) || status.Equals("Rejected", StringComparison.OrdinalIgnoreCase))
            {
                statusClass += " ord-status-cancelled";
            }
            else
            {
                statusClass += " ord-status-processing";
            }

            return string.Format("<span class='{0}'>{1}</span>", statusClass, status);
        }

        protected string GetPaymentStatusBadge(object statusObj)
        {
            string status = statusObj != DBNull.Value ? statusObj.ToString().Trim() : "Pending";
            if (status.Equals("Delivered", StringComparison.OrdinalIgnoreCase) || status.Equals("Shipped", StringComparison.OrdinalIgnoreCase) || status.Equals("Dispatched", StringComparison.OrdinalIgnoreCase))
            {
                return "<span class='ord-pay-status ord-pay-paid'>Paid</span>";
            }
            return "<span class='ord-pay-status ord-pay-pending'>Pending</span>";
        }

        protected string GetRelativeTime(object dtObj)
        {
            if (dtObj == DBNull.Value) return "--";
            DateTime dt = Convert.ToDateTime(dtObj);
            TimeSpan span = DateTime.Now - dt;

            if (span.TotalDays > 365)
            {
                int y = (int)(span.TotalDays / 365);
                return y <= 1 ? "1 year ago" : y + " years ago";
            }
            if (span.TotalDays > 30)
            {
                int m = (int)(span.TotalDays / 30);
                return m <= 1 ? "1 month ago" : m + " months ago";
            }
            if (span.TotalDays >= 1)
            {
                int d = (int)span.TotalDays;
                return d <= 1 ? "1 day ago" : d + " days ago";
            }
            if (span.TotalHours >= 1)
            {
                int h = (int)span.TotalHours;
                return h <= 1 ? "1 hour ago" : h + " hours ago";
            }
            if (span.TotalMinutes >= 1)
            {
                int min = (int)span.TotalMinutes;
                return min <= 1 ? "1 minute ago" : min + " minutes ago";
            }
            return "Just now";
        }

        protected bool IsConfirmButtonVisible(object statusObj)
        {
            string status = statusObj != DBNull.Value ? statusObj.ToString().Trim().ToLower() : "pending";
            return (status == "placed" || status == "processing" || status == "pending");
        }

        protected bool IsReturnButtonVisible(object statusObj)
        {
            string status = statusObj != DBNull.Value ? statusObj.ToString().Trim().ToLower() : "";
            return status.Contains("return");
        }

        protected void btnQuickConfirm_Command(object sender, CommandEventArgs e)
        {
            if (e.CommandName == "ConfirmOrder")
            {
                int orderId = Convert.ToInt32(e.CommandArgument);
                try
                {
                    using (SqlConnection con = new SqlConnection(strcon))
                    {
                        con.Open();
                        // Automated single-step transactional status trigger
                        using (SqlCommand cmd = new SqlCommand("sp_Seller_UpdateOrderStatus", con))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.AddWithValue("@OrderId", orderId);
                            cmd.Parameters.AddWithValue("@Status", "Confirmed");
                            cmd.ExecuteNonQuery();
                        }
                    }
                    
                    // Fluid live data refresh logic
                    BindKPIs();
                    BindOrders();
                }
                catch (Exception ex)
                {
                    Response.Write("<script>alert('Order confirmation failed: " + ex.Message + "');</script>");
                }
            }
        }

        protected void ddlDateFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Live execution trigger on period toggle
            BindKPIs();
            BindOrders();
        }
    }
}
