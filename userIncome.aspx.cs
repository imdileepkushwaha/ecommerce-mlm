using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace ecommerce_mlm
{
    public partial class userIncome : System.Web.UI.Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["Username"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadIncomeDashboard();
            }
        }

        private int GetUserId()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    SqlCommand cmd = new SqlCommand("SELECT Id FROM Users WHERE Username = @u", con);
                    cmd.Parameters.AddWithValue("@u", Session["Username"].ToString());
                    object obj = cmd.ExecuteScalar();
                    return obj != null ? Convert.ToInt32(obj) : 0;
                }
            }
            catch { return 0; }
        }

        private void LoadIncomeDashboard()
        {
            int uid = GetUserId();
            if (uid == 0) return;

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();

                    // 1. FETCH AGGREGATE STATISTICS
                    string qStats = @"
                        SELECT 
                            ISNULL(SUM(IncomeAmount), 0) as Total,
                            ISNULL(SUM(CASE WHEN Status = 'PENDING' THEN IncomeAmount ELSE 0 END), 0) as Pending,
                            ISNULL(SUM(CASE WHEN Status = 'APPROVED' THEN IncomeAmount ELSE 0 END), 0) as Approved,
                            ISNULL(SUM(CASE WHEN Status = 'PAID' THEN IncomeAmount ELSE 0 END), 0) as Paid
                        FROM UserIncome WHERE UserId = @uid";
                    
                    SqlCommand cmdStats = new SqlCommand(qStats, con);
                    cmdStats.Parameters.AddWithValue("@uid", uid);
                    SqlDataReader dr = cmdStats.ExecuteReader();
                    if (dr.Read())
                    {
                        lblTotalEarnings.Text = String.Format("{0:N2}", dr["Total"]);
                        lblPendingAmt.Text = String.Format("{0:N2}", dr["Pending"]);
                        lblApprovedAmt.Text = String.Format("{0:N2}", dr["Approved"]);
                        lblPaidAmt.Text = String.Format("{0:N2}", dr["Paid"]);
                    }
                    dr.Close();

                    // 2. FETCH DETAILED LOGS JOINED WITH REFERRAL USER NAMES
                    string qLogs = @"
                        SELECT 
                            UI.*,
                            U.FullName as RefName,
                            U.Username as RefUser
                        FROM UserIncome UI
                        INNER JOIN Users U ON UI.FromUserId = U.Id
                        WHERE UI.UserId = @uid
                        ORDER BY UI.CreatedAt DESC";
                    
                    SqlCommand cmdLogs = new SqlCommand(qLogs, con);
                    cmdLogs.Parameters.AddWithValue("@uid", uid);
                    SqlDataAdapter da = new SqlDataAdapter(cmdLogs);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        rptIncome.DataSource = dt;
                        rptIncome.DataBind();
                        rptIncome.Visible = true;
                        pnlNoIncome.Visible = false;
                    }
                    else
                    {
                        rptIncome.Visible = false;
                        pnlNoIncome.Visible = true;
                    }
                }
            }
            catch { }
        }

        // CSS Style binding helper
        public string GetStatusClass(string status)
        {
            switch (status.ToUpper())
            {
                case "PENDING": return "status-pill st-pending";
                case "APPROVED": return "status-pill st-approved";
                case "PAID": return "status-pill st-paid";
                default: return "status-pill";
            }
        }
    }
}
