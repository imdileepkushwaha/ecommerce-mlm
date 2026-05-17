using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace EcommerceWebsite
{
    public partial class SellerTransactions : System.Web.UI.Page
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
                BindLedger();
            }
        }

        private void BindLedger()
        {
            try
            {
                int sellerId = Convert.ToInt32(Session["SellerId"]);

                decimal totalCredited = 0;
                decimal totalSettled = 0;

                // 1. Create a structured dynamic ledger table
                DataTable dtLedger = new DataTable();
                dtLedger.Columns.Add("TxnDate", typeof(DateTime));
                dtLedger.Columns.Add("ReferenceNumber", typeof(string));
                dtLedger.Columns.Add("Description", typeof(string));
                dtLedger.Columns.Add("TxnType", typeof(string)); // CREDIT or DEBIT
                dtLedger.Columns.Add("Amount", typeof(decimal));
                dtLedger.Columns.Add("Status", typeof(string)); // SUCCESS, PENDING, FAILED

                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();

                    // --- STREAM A: CREDITS (Delivered Orders Line Items) ---
                    string creditSql = @"
                        SELECT o.Id, o.OrderRef, o.CreatedAt, 
                               ISNULL(SUM(oi.Quantity * oi.UnitPrice), 0) as EarningsAmount
                        FROM OrderItems oi
                        JOIN Orders o ON oi.OrderId = o.Id
                        JOIN SellerProducts p ON oi.ProductId = p.Id
                        WHERE p.SellerId = @sid AND o.Status = 'Delivered'
                        GROUP BY o.Id, o.OrderRef, o.CreatedAt";
                    using (SqlCommand cmd = new SqlCommand(creditSql, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", sellerId);
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            while (dr.Read())
                            {
                                decimal amt = Convert.ToDecimal(dr["EarningsAmount"]);
                                totalCredited += amt;

                                DataRow row = dtLedger.NewRow();
                                row["TxnDate"] = Convert.ToDateTime(dr["CreatedAt"]);
                                row["ReferenceNumber"] = "TXN-" + dr["OrderRef"].ToString();
                                row["Description"] = "Earnings credited for Order #" + dr["OrderRef"].ToString();
                                row["TxnType"] = "CREDIT";
                                row["Amount"] = amt;
                                row["Status"] = "SUCCESS";
                                dtLedger.Rows.Add(row);
                            }
                        }
                    }

                    // --- STREAM B: DEBITS (Withdrawal Requests) ---
                    string debitSql = @"
                        SELECT Id, ReferenceNumber, RequestAmount, Status, CreatedAt, AdminRemarks 
                        FROM SellerPayoutRequests 
                        WHERE SellerId = @sid";
                    using (SqlCommand cmd = new SqlCommand(debitSql, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", sellerId);
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            while (dr.Read())
                            {
                                decimal amt = Convert.ToDecimal(dr["RequestAmount"]);
                                string status = dr["Status"].ToString().Trim().ToUpper();

                                // Track only paid out settlements as fully debited
                                if (status == "PAID")
                                {
                                    totalSettled += amt;
                                }

                                string formattedRef = dr["ReferenceNumber"] != DBNull.Value && !string.IsNullOrEmpty(dr["ReferenceNumber"].ToString())
                                    ? dr["ReferenceNumber"].ToString()
                                    : "WR" + Convert.ToInt32(dr["Id"]).ToString("D6");

                                string description = "Payout settlement request placed";
                                if (status == "REJECTED")
                                {
                                    description = "Payout settlement request denied";
                                }

                                DataRow row = dtLedger.NewRow();
                                row["TxnDate"] = Convert.ToDateTime(dr["CreatedAt"]);
                                row["ReferenceNumber"] = formattedRef;
                                row["Description"] = description;
                                row["TxnType"] = "DEBIT";
                                row["Amount"] = amt;
                                row["Status"] = status == "PAID" ? "SUCCESS" : (status == "REJECTED" ? "FAILED" : "PENDING");
                                dtLedger.Rows.Add(row);
                            }
                        }
                    }
                }

                // 2. Sort the final combined ledger chronologically descending
                DataView dv = new DataView(dtLedger);
                dv.Sort = "TxnDate DESC";
                DataTable dtSorted = dv.ToTable();

                int count = dtSorted.Rows.Count;
                litTransactionsBadgeCount.Text = count.ToString();
                litLedgerPaginationTotal.Text = count.ToString();
                litLedgerPaginationRange.Text = count > 0 ? "1-" + count : "0-0";

                // 3. Bind to visual elements
                litTotalCredited.Text = totalCredited.ToString("N0");
                litTotalSettled.Text = totalSettled.ToString("N0");
                
                decimal netValue = totalCredited - totalSettled;
                if (netValue < 0) netValue = 0;
                litNetValue.Text = netValue.ToString("N0");

                if (count > 0)
                {
                    rptTransactions.DataSource = dtSorted;
                    rptTransactions.DataBind();
                    rptTransactions.Visible = true;
                    phEmptyLedger.Visible = false;
                }
                else
                {
                    rptTransactions.DataSource = null;
                    rptTransactions.DataBind();
                    rptTransactions.Visible = false;
                    phEmptyLedger.Visible = true;
                }
            }
            catch (Exception ex)
            {
                ShowAlert("alert-danger", "Ledger compilation failure: " + ex.Message);
            }
        }

        protected string GetLedgerStatusBadge(object statusObj)
        {
            string status = statusObj != DBNull.Value ? statusObj.ToString().Trim().ToUpper() : "SUCCESS";
            string cssClass = "earn-table-badge";

            if (status == "SUCCESS")
            {
                cssClass += " badge-delivered";
            }
            else if (status == "FAILED")
            {
                cssClass += " badge-cancelled";
            }
            else
            {
                cssClass += " badge-pending";
            }

            return string.Format("<span class='{0}'>{1}</span>", cssClass, status);
        }

        private void ShowAlert(string css, string msg)
        {
            lblMsg.Text = msg;
            lblMsg.CssClass = "alert " + css;
            lblMsg.Style["background-color"] = css.Contains("danger") ? "#fef2f2" : "#f0fdf4";
            lblMsg.Style["color"] = css.Contains("danger") ? "#991b1b" : "#166534";
            lblMsg.Style["border"] = css.Contains("danger") ? "1px solid #fee2e2" : "1px solid #dcfce7";
            lblMsg.Visible = true;
        }
    }
}
