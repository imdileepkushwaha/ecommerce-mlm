using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ecommerce_mlm.admin
{
    public partial class ManagePayouts : System.Web.UI.Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["AdminId"] == null)
            {
                Response.Redirect("AdminLogin.aspx");
                return;
            }

            // 1. Autonomous Schema Check/Provision on boot
            EnsurePayoutSchema();

            if (!IsPostBack)
            {
                BindPayoutGrid();
            }
        }

        private void EnsurePayoutSchema()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string sql = @"
                        IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PayoutRequests')
                        BEGIN
                            CREATE TABLE PayoutRequests (
                                Id INT PRIMARY KEY IDENTITY(1,1),
                                UserId INT NOT NULL,
                                RequestAmount DECIMAL(18, 2) NOT NULL,
                                TdsDeduction DECIMAL(18, 2) NOT NULL DEFAULT 0,
                                AdminCharges DECIMAL(18, 2) NOT NULL DEFAULT 0,
                                NetPayable DECIMAL(18, 2) NOT NULL,
                                Status NVARCHAR(50) NOT NULL DEFAULT 'PENDING', -- PENDING, PAID, REJECTED
                                TransactionId NVARCHAR(100) NULL,
                                PaidDate DATETIME NULL,
                                AdminRemarks NVARCHAR(MAX) NULL,
                                CreatedAt DATETIME DEFAULT GETDATE()
                            );
                        END";
                    new SqlCommand(sql, con).ExecuteNonQuery();
                }
            }
            catch { }
        }

        private void BindPayoutGrid()
        {
            try
            {
                string filter = ddlStatusFilter.SelectedValue;
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string sql = @"
                        SELECT 
                            p.Id,
                            p.UserId,
                            u.FullName,
                            u.Username,
                            p.RequestAmount,
                            p.TdsDeduction,
                            p.AdminCharges,
                            p.NetPayable,
                            p.Status,
                            p.TransactionId,
                            p.PaidDate,
                            p.CreatedAt,
                            b.BankName,
                            b.AccountNumber,
                            b.IFSCCode,
                            b.AccountHolderName
                        FROM PayoutRequests p
                        INNER JOIN Users u ON p.UserId = u.Id
                        LEFT JOIN UserBankDetails b ON u.Id = b.UserId
                        WHERE 1=1";

                    if (filter != "ALL")
                    {
                        sql += " AND p.Status = @status";
                    }

                    sql += " ORDER BY p.CreatedAt DESC";

                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        if (filter != "ALL")
                        {
                            cmd.Parameters.AddWithValue("@status", filter);
                        }

                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        
                        gvPayouts.DataSource = dt;
                        gvPayouts.DataBind();
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMsg("alert-danger", "Error Loading Payouts: " + ex.Message);
            }
        }

        protected void ddlStatusFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindPayoutGrid();
        }

        protected void gvPayouts_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "PaidTrigger")
            {
                string payoutId = e.CommandArgument.ToString();
                hfSelectedPayoutId.Value = payoutId;
                
                // Open Modal by script
                ScriptManager.RegisterStartupScript(this, this.GetType(), "PopPaid", "openActionModal('paid');", true);
            }
            else if (e.CommandName == "RejectTrigger")
            {
                string payoutId = e.CommandArgument.ToString();
                hfSelectedPayoutId.Value = payoutId;

                // Open Modal by script
                ScriptManager.RegisterStartupScript(this, this.GetType(), "PopReject", "openActionModal('reject');", true);
            }
        }

        protected void btnConfirmPaid_Click(object sender, EventArgs e)
        {
            string id = hfSelectedPayoutId.Value;
            string txn = txtTxnId.Text.Trim();

            if (string.IsNullOrEmpty(txn))
            {
                ShowMsg("alert-danger", "Please enter a Transaction ID (UTR).");
                return;
            }

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string sql = "UPDATE PayoutRequests SET Status = 'PAID', TransactionId = @txn, PaidDate = GETDATE() WHERE Id = @id";
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@txn", txn);
                        cmd.Parameters.AddWithValue("@id", id);
                        cmd.ExecuteNonQuery();
                    }
                }
                ShowMsg("alert-success", "Payout successfully marked as PAID and settled!");
                txtTxnId.Text = "";
                BindPayoutGrid();
            }
            catch (Exception ex)
            {
                ShowMsg("alert-danger", "Update Failed: " + ex.Message);
            }
        }

        protected void btnConfirmReject_Click(object sender, EventArgs e)
        {
            string id = hfSelectedPayoutId.Value;
            string reason = txtReason.Text.Trim();

            if (string.IsNullOrEmpty(reason))
            {
                ShowMsg("alert-danger", "Please enter rejection reason.");
                return;
            }

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string sql = "UPDATE PayoutRequests SET Status = 'REJECTED', AdminRemarks = @reason WHERE Id = @id";
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@reason", reason);
                        cmd.Parameters.AddWithValue("@id", id);
                        cmd.ExecuteNonQuery();
                    }
                }
                ShowMsg("alert-success", "Payout request successfully Rejected.");
                txtReason.Text = "";
                BindPayoutGrid();
            }
            catch (Exception ex)
            {
                ShowMsg("alert-danger", "Rejection Failed: " + ex.Message);
            }
        }

        private void ShowMsg(string css, string msg)
        {
            pnlMsg.CssClass = "alert " + css + " alert-dismissible fade show u-mb-20";
            lblMsg.Text = msg;
            pnlMsg.Visible = true;
        }
    }
}
