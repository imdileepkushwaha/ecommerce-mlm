using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace ecommerce_mlm.admin
{
    public partial class UserDetails : Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.QueryString["uid"] == null)
            {
                Response.Redirect("ManageUsers.aspx");
                return;
            }

            if (!IsPostBack)
            {
                string uid = Request.QueryString["uid"].ToString();
                LoadCompleteProfile(uid);
            }
        }

        private void LoadCompleteProfile(string userId)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();

                    // 1. Fetch Primary User Data
                    SqlCommand cmdUser = new SqlCommand("SELECT * FROM Users WHERE Id = @id", con);
                    cmdUser.Parameters.AddWithValue("@id", userId);
                    SqlDataReader drUser = cmdUser.ExecuteReader();
                    
                    string currentUsername = "";
                    
                    if (drUser.HasRows)
                    {
                        drUser.Read();
                        currentUsername = drUser["Username"].ToString();
                        
                        string fullName = drUser["FullName"].ToString();
                        litFullName.Text = fullName;
                        litUsername.Text = currentUsername;
                        litEmail.Text = drUser["Email"].ToString();
                        litMobile.Text = drUser["Mobile"].ToString();
                        litJoinDate.Text = Convert.ToDateTime(drUser["CreatedAt"]).ToString("dd MMM yyyy");
                        litSponsor.Text = drUser["SponsorId"].ToString();
                        litGender.Text = drUser["Gender"] != DBNull.Value ? drUser["Gender"].ToString() : "N/A";
                        
                        bool isActive = Convert.ToBoolean(drUser["IsActive"]);
                        lblStatusBadge.Text = isActive ? "ACTIVE" : "SUSPENDED";
                        lblStatusBadge.CssClass = isActive ? "badge badge-success" : "badge badge-danger";
                        
                        // Initial Generator
                        if(!string.IsNullOrEmpty(fullName)) {
                           string[] p = fullName.Trim().Split(' ');
                           litInitials.Text = p.Length >= 2 ? (p[0][0].ToString() + p[1][0].ToString()).ToUpper() : fullName.Substring(0, Math.Min(fullName.Length, 2)).ToUpper();
                        }
                    }
                    else
                    {
                        Response.Redirect("ManageUsers.aspx");
                    }
                    drUser.Close();

                    // 2. Aggregate Statistics (Income, Rewards, Team Size)
                    // Income
                    SqlCommand cmdInc = new SqlCommand("SELECT ISNULL(SUM(IncomeAmount), 0) FROM UserIncome WHERE UserId = @id", con);
                    cmdInc.Parameters.AddWithValue("@id", userId);
                    object incObj = cmdInc.ExecuteScalar();
                    litTotalIncome.Text = Convert.ToDecimal(incObj).ToString("N2");

                    // Team Size
                    if (!string.IsNullOrEmpty(currentUsername))
                    {
                        SqlCommand cmdTeam = new SqlCommand("SELECT COUNT(*) FROM Users WHERE SponsorId = @u", con);
                        cmdTeam.Parameters.AddWithValue("@u", currentUsername);
                        litTeamCount.Text = cmdTeam.ExecuteScalar().ToString();
                    }

                    // Rewards
                    SqlCommand cmdRew = new SqlCommand("SELECT ISNULL(SUM(PointsEarned), 0) FROM UserRewards WHERE UserId = @id AND Status = 'CREDITED'", con);
                    cmdRew.Parameters.AddWithValue("@id", userId);
                    litRewardPoints.Text = Convert.ToInt64(cmdRew.ExecuteScalar()).ToString("N0");

                    // 3. Bind Bank Accounts
                    SqlCommand cmdBank = new SqlCommand("SELECT * FROM UserBankDetails WHERE UserId = @id ORDER BY CreatedAt DESC", con);
                    cmdBank.Parameters.AddWithValue("@id", userId);
                    SqlDataAdapter daBank = new SqlDataAdapter(cmdBank);
                    DataTable dtBank = new DataTable();
                    daBank.Fill(dtBank);
                    
                    if(dtBank.Rows.Count > 0) {
                        rptBank.DataSource = dtBank;
                        rptBank.DataBind();
                        pnlNoBank.Visible = false;
                    } else {
                        pnlNoBank.Visible = true;
                    }

                    // 4. Bind Addresses
                    SqlCommand cmdAddr = new SqlCommand("SELECT * FROM Addresses WHERE UserId = @id ORDER BY IsDefault DESC, CreatedAt DESC", con);
                    cmdAddr.Parameters.AddWithValue("@id", userId);
                    SqlDataAdapter daAddr = new SqlDataAdapter(cmdAddr);
                    DataTable dtAddr = new DataTable();
                    daAddr.Fill(dtAddr);
                    
                    if(dtAddr.Rows.Count > 0) {
                        rptAddress.DataSource = dtAddr;
                        rptAddress.DataBind();
                        pnlNoAddr.Visible = false;
                    } else {
                        pnlNoAddr.Visible = true;
                    }
                }
            }
            catch (Exception ex)
            {
                // Silent handling for smooth presentation
            }
        }
    }
}
