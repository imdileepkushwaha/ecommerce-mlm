using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ecommerce_mlm.admin
{
    public partial class AccountDeletions : Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadRequests();
            }
        }

        private void LoadRequests()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();

                    // 1. Fetch User Deletion Requests (Strictly PENDING)
                    string uSql = @"SELECT R.Id, R.RequestDate, R.Status, U.FullName, U.Email, U.Mobile 
                                   FROM AccountDeleteRequests R
                                   INNER JOIN Users U ON R.UserId = U.Id
                                   WHERE R.Status = 'PENDING'
                                   ORDER BY R.RequestDate DESC";
                    
                    SqlDataAdapter daU = new SqlDataAdapter(uSql, con);
                    DataTable dtUsers = new DataTable();
                    daU.Fill(dtUsers);

                    rptUsers.DataSource = dtUsers;
                    rptUsers.DataBind();
                    pnlUsersEmpty.Visible = (dtUsers.Rows.Count == 0);
                    lblUserCount.Text = dtUsers.Rows.Count.ToString();


                    // 2. Fetch Seller Deletion Requests (Strictly Pending)
                    string sSql = @"SELECT Id, FullName, Email, DeactivationDate, DeletionStatus 
                                   FROM SellerUsers 
                                   WHERE DeletionStatus = 'Pending'
                                   ORDER BY DeactivationDate DESC";
                    
                    SqlDataAdapter daS = new SqlDataAdapter(sSql, con);
                    DataTable dtSellers = new DataTable();
                    daS.Fill(dtSellers);

                    rptSellers.DataSource = dtSellers;
                    rptSellers.DataBind();
                    pnlSellersEmpty.Visible = (dtSellers.Rows.Count == 0);
                    lblSellerCount.Text = dtSellers.Rows.Count.ToString();

                    // 3. Consolidated Resolution History
                    string hSql = @"SELECT 'User' as EType, U.FullName, U.Email, R.RequestDate as EDate, R.Status as EStatus 
                                   FROM AccountDeleteRequests R JOIN Users U ON R.UserId = U.Id 
                                   WHERE R.Status IN ('APPROVED', 'CANCELLED')
                                   UNION ALL
                                   SELECT 'Seller' as EType, FullName, Email, DeactivationDate as EDate, DeletionStatus as EStatus 
                                   FROM SellerUsers 
                                   WHERE DeletionStatus = 'Approved'
                                   ORDER BY EDate DESC";
                    
                    SqlDataAdapter daH = new SqlDataAdapter(hSql, con);
                    DataTable dtHist = new DataTable();
                    daH.Fill(dtHist);
                    rptHistory.DataSource = dtHist;
                    rptHistory.DataBind();
                    pnlHistEmpty.Visible = (dtHist.Rows.Count == 0);
                }
            }
            catch (Exception ex)
            {
                // Log silence
            }
        }

        protected void rptAction_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string[] args = e.CommandArgument.ToString().Split('|');
            if(args.Length < 2) return;
            string id = args[0];
            string action = e.CommandName; // ApproveRequest
            string type = args[1]; // User or Seller

            try {
                using(SqlConnection con = new SqlConnection(strcon)) {
                    con.Open();
                    if(action == "ApproveRequest") {
                        if(type == "User") {
                            string sql = "UPDATE AccountDeleteRequests SET Status = 'APPROVED', AdminApprovedDate = GETDATE() WHERE Id = @id";
                            SqlCommand cmd = new SqlCommand(sql, con);
                            cmd.Parameters.AddWithValue("@id", id);
                            cmd.ExecuteNonQuery();
                        } else {
                            string sql = "UPDATE SellerUsers SET DeletionStatus = 'Approved' WHERE Id = @id";
                            SqlCommand cmd = new SqlCommand(sql, con);
                            cmd.Parameters.AddWithValue("@id", id);
                            cmd.ExecuteNonQuery();
                        }
                    } else if(action == "RejectRequest") {
                        if(type == "User") {
                            string sql = "UPDATE AccountDeleteRequests SET Status = 'CANCELLED' WHERE Id = @id";
                            SqlCommand cmd = new SqlCommand(sql, con);
                            cmd.Parameters.AddWithValue("@id", id);
                            cmd.ExecuteNonQuery();
                        } else {
                            string sql = "UPDATE SellerUsers SET DeletionStatus = 'None' WHERE Id = @id";
                            SqlCommand cmd = new SqlCommand(sql, con);
                            cmd.Parameters.AddWithValue("@id", id);
                            cmd.ExecuteNonQuery();
                        }
                    }
                }
                Response.Redirect("AccountDeletions.aspx");
            } catch { }
        }
        protected string GetHistStatusClass(object status)
        {
            string s = status != null ? status.ToString().ToUpper() : "";
            if(s == "APPROVED") return "badge-success";
            if(s == "CANCELLED") return "badge-danger";
            return "badge-info";
        }
    }
}
