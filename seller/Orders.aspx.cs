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
                    // Get KPIs using conditional counts securely.
                    string query = @"
                        SELECT 
                            COUNT(DISTINCT o.Id) as TotalOrders,
                            COUNT(DISTINCT CASE WHEN o.Status IN ('Pending', 'Placed', 'Processing', 'Confirmed') THEN o.Id END) as NeedsConfirm,
                            COUNT(DISTINCT CASE WHEN o.Status IN ('Shipped', 'Dispatched', 'In Transit') THEN o.Id END) as InTransit,
                            COUNT(DISTINCT CASE WHEN o.Status = 'Delivered' THEN o.Id END) as Delivered,
                            COUNT(DISTINCT CASE WHEN o.Status LIKE '%Return%' THEN o.Id END) as ReturnRequests
                        FROM Orders o
                        JOIN OrderItems oi ON o.Id = oi.OrderId
                        JOIN SellerProducts p ON oi.ProductId = p.Id
                        WHERE p.SellerId = @SellerId" + GetDateFilterSql();

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@SellerId", sellerId);
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
                    string query = @"
                        SELECT DISTINCT 
                            o.Id,
                            o.OrderRef,
                            o.TotalAmount,
                            o.Status,
                            o.CreatedAt,
                            o.PaymentMode,
                            ISNULL(u.FullName, 'Guest Customer') as CustName,
                            ISNULL(u.Email, 'noemail@yopmail.com') as CustEmail,
                            (SELECT TOP 1 ISNULL(p3.Category, 'General')
                             FROM OrderItems oi3 
                             JOIN SellerProducts p3 ON oi3.ProductId = p3.Id 
                             WHERE oi3.OrderId = o.Id AND p3.SellerId = @SellerId) as TopCategory,
                            (SELECT SUM(oi2.Quantity) 
                             FROM OrderItems oi2 
                             JOIN SellerProducts p2 ON oi2.ProductId = p2.Id 
                             WHERE oi2.OrderId = o.Id AND p2.SellerId = @SellerId) as SellerItemCount,
                            (SELECT SUM(oi2.UnitPrice * oi2.Quantity) 
                             FROM OrderItems oi2 
                             JOIN SellerProducts p2 ON oi2.ProductId = p2.Id 
                             WHERE oi2.OrderId = o.Id AND p2.SellerId = @SellerId) as SellerTotalAmount
                        FROM Orders o
                        LEFT JOIN Users u ON o.UserId = u.Id
                        JOIN OrderItems oi ON o.Id = oi.OrderId
                        JOIN SellerProducts p ON oi.ProductId = p.Id
                        WHERE p.SellerId = @SellerId" + GetDateFilterSql() + @"
                        ORDER BY o.Id DESC";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@SellerId", sellerId);
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
                        // Explicit direct SQL override for lightning-fast status updates
                        string updateSql = "UPDATE Orders SET Status = 'Confirmed', UpdatedAt = GETDATE() WHERE Id = @OrderId";
                        using (SqlCommand cmd = new SqlCommand(updateSql, con))
                        {
                            cmd.Parameters.AddWithValue("@OrderId", orderId);
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

        private string GetDateFilterSql()
        {
            string val = ddlDateFilter.SelectedValue;
            if (val == "24h") return " AND o.CreatedAt >= DATEADD(hour, -24, GETDATE()) ";
            if (val == "7d") return " AND o.CreatedAt >= DATEADD(day, -7, GETDATE()) ";
            if (val == "30d") return " AND o.CreatedAt >= DATEADD(day, -30, GETDATE()) ";
            return ""; // Returns empty clause for "All time" default
        }
    }
}
