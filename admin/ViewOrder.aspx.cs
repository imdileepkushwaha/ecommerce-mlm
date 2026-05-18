using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ecommerce_mlm.admin
{
    public partial class ViewOrder : Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;
        int _orderId;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!int.TryParse(Request.QueryString["id"], out _orderId) || _orderId < 1)
            {
                ShowNotFound();
                return;
            }

            if (!IsPostBack)
            {
                ShowFlash();
                LoadOrder();
            }
        }

        private void ShowFlash()
        {
            string msg = Request.QueryString["msg"];
            if (string.IsNullOrEmpty(msg)) return;

            pnlFlash.Visible = true;
            if (msg == "updated")
            {
                pnlFlash.CssClass = "mu-flash mu-flash-success";
                icoFlash.Attributes["class"] = "fas fa-check-circle";
                litFlash.Text = "Order status updated successfully.";
            }
        }

        private void LoadOrder()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();

                    string sql = @"SELECT O.Id, O.TotalAmount, O.ItemCount, O.Status, O.CreatedAt, O.UpdatedAt,
                        O.PaymentMode, O.OrderRef, O.DiscountAmount,
                        U.FullName, U.Email,
                        A.FullName AS ShipName, A.StreetAddress, A.City, A.State, A.ZipCode, A.PhoneNumber
                        FROM Orders O
                        INNER JOIN Users U ON O.UserId = U.Id
                        LEFT JOIN Addresses A ON O.AddressId = A.Id
                        WHERE O.Id = @id";

                    DataRow row = null;
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@id", _orderId);
                        DataTable dt = new DataTable();
                        new SqlDataAdapter(cmd).Fill(dt);
                        if (dt.Rows.Count == 0)
                        {
                            ShowNotFound();
                            return;
                        }
                        row = dt.Rows[0];
                    }

                    string orderRef = row["OrderRef"] != DBNull.Value && !string.IsNullOrWhiteSpace(row["OrderRef"].ToString())
                        ? row["OrderRef"].ToString().Trim()
                        : "ORD" + row["Id"];

                    litPageTitle.Text = orderRef;
                    litPageSub.Text = "Order #" + row["Id"] + " · placed " +
                        Convert.ToDateTime(row["CreatedAt"]).ToString("MMM dd, yyyy · hh:mm tt", CultureInfo.InvariantCulture);

                    string status = row["Status"] != DBNull.Value ? row["Status"].ToString().Trim() : "Pending";
                    litStatus.Text = FormatStatusBadge(status);
                    litTotal.Text = "₹" + Convert.ToDecimal(row["TotalAmount"]).ToString("N0", CultureInfo.InvariantCulture);
                    litItemCount.Text = row["ItemCount"] != DBNull.Value ? row["ItemCount"].ToString() : "0";
                    litPayment.Text = Server.HtmlEncode(row["PaymentMode"] != DBNull.Value ? row["PaymentMode"].ToString() : "COD");
                    litPlaced.Text = Convert.ToDateTime(row["CreatedAt"]).ToString("MMM dd, yyyy · hh:mm tt", CultureInfo.InvariantCulture);
                    litCustomer.Text = Server.HtmlEncode(row["FullName"] != DBNull.Value ? row["FullName"].ToString() : "—");
                    litEmail.Text = Server.HtmlEncode(row["Email"] != DBNull.Value ? row["Email"].ToString() : "—");
                    litShipping.Text = FormatShipping(row);

                    LoadItems(con);
                    SetupActions(status);

                    pnlContent.Visible = true;
                    pnlError.Visible = false;
                }
            }
            catch
            {
                ShowNotFound();
            }
        }

        private void LoadItems(SqlConnection con)
        {
            string sql = @"SELECT OI.ProductName, OI.Quantity, OI.UnitPrice AS Price
                FROM OrderItems OI WHERE OI.OrderId = @id ORDER BY OI.Id";
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@id", _orderId);
                DataTable dt = new DataTable();
                new SqlDataAdapter(cmd).Fill(dt);
                rptItems.DataSource = dt;
                rptItems.DataBind();
            }
        }

        private void SetupActions(string status)
        {
            string s = status.ToLowerInvariant();
            btnShip.Visible = s == "pending" || s == "processing" || s == "placed" || s == "confirmed";
            btnDeliver.Visible = s == "shipped" || s == "dispatched" || s == "out for delivery";
            btnCancel.Visible = s != "delivered" && s != "completed" && s != "cancelled" && s != "canceled";
            pnlActions.Visible = btnShip.Visible || btnDeliver.Visible || btnCancel.Visible;
        }

        protected void btnShip_Click(object sender, EventArgs e)
        {
            UpdateStatus("Shipped");
        }

        protected void btnDeliver_Click(object sender, EventArgs e)
        {
            UpdateStatus("Delivered");
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            UpdateStatus("Cancelled");
        }

        private void UpdateStatus(string newStatus)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    using (SqlCommand cmd = new SqlCommand("UPDATE Orders SET Status = @stat, UpdatedAt = GETDATE() WHERE Id = @id", con))
                    {
                        cmd.Parameters.AddWithValue("@stat", newStatus);
                        cmd.Parameters.AddWithValue("@id", _orderId);
                        cmd.ExecuteNonQuery();
                    }
                }
                Response.Redirect("ViewOrder.aspx?id=" + _orderId + "&msg=updated");
            }
            catch
            {
                Response.Redirect("ViewOrder.aspx?id=" + _orderId + "&msg=error");
            }
        }

        private void ShowNotFound()
        {
            pnlContent.Visible = false;
            pnlError.Visible = true;
            pnlFlash.Visible = false;
        }

        private string FormatStatusBadge(string status)
        {
            string key = status.ToLowerInvariant().Replace(" ", "-");
            string css = "mo-status-default";
            if (key == "delivered" || key == "completed") css = "mo-status-delivered";
            else if (key == "cancelled" || key == "canceled") css = "mo-status-cancelled";
            else if (key == "pending" || key == "processing" || key == "placed" || key == "confirmed") css = "mo-status-processing";
            else if (key == "shipped" || key == "dispatched" || key == "out-for-delivery") css = "mo-status-shipped";
            return "<span class=\"mo-status " + css + "\">" + Server.HtmlEncode(status) + "</span>";
        }

        private string FormatShipping(DataRow row)
        {
            string name = row["ShipName"] != DBNull.Value ? row["ShipName"].ToString().Trim() : "";
            string line = row["StreetAddress"] != DBNull.Value ? row["StreetAddress"].ToString().Trim() : "";
            string city = row["City"] != DBNull.Value ? row["City"].ToString().Trim() : "";
            string state = row["State"] != DBNull.Value ? row["State"].ToString().Trim() : "";
            string zip = row["ZipCode"] != DBNull.Value ? row["ZipCode"].ToString().Trim() : "";
            string phone = row["PhoneNumber"] != DBNull.Value ? row["PhoneNumber"].ToString().Trim() : "";

            if (string.IsNullOrEmpty(name) && string.IsNullOrEmpty(line))
                return "—";

            var parts = new System.Collections.Generic.List<string>();
            if (!string.IsNullOrEmpty(name)) parts.Add(name);
            if (!string.IsNullOrEmpty(line)) parts.Add(line);
            if (!string.IsNullOrEmpty(city)) parts.Add(city);
            if (!string.IsNullOrEmpty(state)) parts.Add(state);
            if (!string.IsNullOrEmpty(zip)) parts.Add(zip);
            if (!string.IsNullOrEmpty(phone)) parts.Add("Ph: " + phone);

            return Server.HtmlEncode(string.Join(" · ", parts));
        }
    }
}
