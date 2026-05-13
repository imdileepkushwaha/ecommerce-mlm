using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;

namespace ecommerce_mlm.admin
{
    public partial class GenealogyTree : System.Web.UI.Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["AdminId"] == null)
            {
                Response.Redirect("AdminLogin.aspx");
                return;
            }

            if (!IsPostBack)
            {
                string initialRoot = Request.QueryString["root"];
                if (!string.IsNullOrEmpty(initialRoot))
                {
                    txtSearchUser.Text = initialRoot;
                    RenderAdminTree(initialRoot);
                }
                else
                {
                    // Fetch default system administrator / first user as fallback
                    string fallbackRoot = GetFallbackRootUser();
                    if (!string.IsNullOrEmpty(fallbackRoot))
                    {
                        txtSearchUser.Text = fallbackRoot;
                        RenderAdminTree(fallbackRoot);
                    }
                }
            }
        }

        private string GetFallbackRootUser()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    SqlCommand cmd = new SqlCommand("SELECT TOP 1 Username FROM Users ORDER BY CreatedAt ASC", con);
                    object res = cmd.ExecuteScalar();
                    return res != null ? res.ToString() : "";
                }
            }
            catch { return ""; }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            lblMsg.Visible = false;
            string term = txtSearchUser.Text.Trim();
            if (string.IsNullOrEmpty(term))
            {
                lblMsg.Text = "Please specify a target username.";
                lblMsg.CssClass = "alert alert-danger u-d-block u-mb-20";
                lblMsg.Visible = true;
                return;
            }

            if (!UserExists(term))
            {
                lblMsg.Text = "Target user node could not be verified in the registry.";
                lblMsg.CssClass = "alert alert-danger u-d-block u-mb-20";
                lblMsg.Visible = true;
                return;
            }

            RenderAdminTree(term);
        }

        private bool UserExists(string uname)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Users WHERE Username = @u", con);
                    cmd.Parameters.AddWithValue("@u", uname);
                    return (int)cmd.ExecuteScalar() > 0;
                }
            }
            catch { return false; }
        }

        private void RenderAdminTree(string rootUser)
        {
            DataTable dtTreeData = new DataTable();
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    using (SqlCommand cmd = new SqlCommand("sp_GetNetworkTree", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@RootUsername", rootUser);
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        da.Fill(dtTreeData);
                    }
                }
            }
            catch (Exception ex)
            {
                lblMsg.Text = "Stored Procedure Execution failure: " + ex.Message;
                lblMsg.CssClass = "alert alert-danger u-d-block u-mb-20";
                lblMsg.Visible = true;
                return;
            }

            StringBuilder sb = new StringBuilder();
            sb.Append("<ul>");
            
            // Standard 4-level vertical recursive constructor passing rootUser as initial sponsor
            sb.Append(BuildRecursiveAdminNode(rootUser, 1, dtTreeData, "", ""));


            sb.Append("</ul>");
            litTreeOutput.Text = sb.ToString();
        }

        private string BuildRecursiveAdminNode(string username, int level, DataTable dtSource, string parentSponsor, string position)
        {
            if (level > 4) return "";


            bool isSlotAvailable = (username == "AVAILABLE");
            bool activeState = false;
            string fullNameVal = "-";
            string sponsorIdVal = "-";
            int directCount = 0;

            // Fetch details from cached runtime datatable
            DataRow[] matches = dtSource.Select(string.Format("Username = '{0}'", username.Replace("'", "''")));

            if (!isSlotAvailable && matches.Length > 0)
            {
                DataRow dr = matches[0];
                activeState = Convert.ToBoolean(dr["IsActive"]);
                fullNameVal = dr["FullName"].ToString();
                sponsorIdVal = dr["SponsorId"].ToString();
                directCount = Convert.ToInt32(dr["DirectTeamCount"]);
            }
            else
            {
                isSlotAvailable = true;
            }

            StringBuilder nodeMarkup = new StringBuilder();
            nodeMarkup.Append("<li>");

            if (isSlotAvailable)
            {
                // Clickable vacant slot targeting dynamic sponsor registration modal with position awareness
                nodeMarkup.AppendFormat(@"
                    <a href='javascript:void(0)' onclick=""openQuickRegModal('{0}', '{2}')"" class='tree-node node-empty' title='Click to Register Direct Member Here!'>
                        <div class='node-avatar'><i class='fas fa-plus-circle'></i></div>
                        <div class='node-name' style='color:#0ea5e9;'>+ Add Direct</div>
                        <div class='node-role'>{1}</div>
                    </a>", parentSponsor, "Lvl " + level, position);
            }

            else
            {
                string cssModifier = activeState ? "node-active" : "node-deactive";
                string nodeIcon = activeState ? "fa-user-check" : "fa-user-times";
                
                // High fidelity clickable node routing to refocus
                nodeMarkup.AppendFormat(@"
                    <a href='GenealogyTree.aspx?root={0}' class='tree-node {1}' title='Click to center on {0}'>
                        <div class='node-avatar'><i class='fas {2}'></i></div>
                        <div class='node-name'>{0}</div>
                        <div class='node-role'>{3}</div>
                        <div class='node-tooltip'>
                            <div style='border-bottom:1px solid rgba(255,255,255,0.1); padding-bottom:6px; margin-bottom:8px; font-weight:700; color:#38bdf8;'>
                                <i class='fas fa-id-badge u-mr-5'></i> User Details
                            </div>
                            <table class='tip-tbl'>
                                <tr><th>Alias:</th><td>{4}</td></tr>
                                <tr><th>Username:</th><td>{0}</td></tr>
                                <tr><th>Sponsor:</th><td>{5}</td></tr>
                                <tr><th>Direct Team:</th><td>{6}</td></tr>
                                <tr><th>Status:</th><td>{7}</td></tr>
                            </table>
                            <div style='font-size: 9.5px; text-align: center; margin-top: 8px; color: #94a3b8; border-top: 1px dashed rgba(255,255,255,0.15); padding-top: 6px;'>
                                Click node to center tree
                            </div>
                        </div>
                    </a>", 
                    username, cssModifier, nodeIcon, "Lvl " + level,
                    fullNameVal, sponsorIdVal, directCount, 
                    (activeState ? "<span style='color:#4ade80; font-weight:700;'>ACTIVE</span>" : "<span style='color:#f87171; font-weight:700;'>INACTIVE</span>")
                );
            }

            if (level < 4)
            {
                string leftLeaf = "AVAILABLE";
                string rightLeaf = "AVAILABLE";

                if (!isSlotAvailable)
                {
                    // Match explicit Physical Placement Children on the Left and Right paths from Pre-Fetched data
                    DataRow[] leftMatch = dtSource.Select(string.Format("ParentId = '{0}' AND Position = 'Left' AND Username <> '{0}'", username.Replace("'", "''")));
                    DataRow[] rightMatch = dtSource.Select(string.Format("ParentId = '{0}' AND Position = 'Right' AND Username <> '{0}'", username.Replace("'", "''")));
                    
                    if (leftMatch.Length > 0) leftLeaf = leftMatch[0]["Username"].ToString();
                    if (rightMatch.Length > 0) rightLeaf = rightMatch[0]["Username"].ToString();
                }

                nodeMarkup.Append("<ul>");
                nodeMarkup.Append(BuildRecursiveAdminNode(leftLeaf, level + 1, dtSource, username, "Left")); 
                nodeMarkup.Append(BuildRecursiveAdminNode(rightLeaf, level + 1, dtSource, username, "Right")); 
                nodeMarkup.Append("</ul>");
            }


            nodeMarkup.Append("</li>");
            return nodeMarkup.ToString();
        }

        protected void btnModalSubmit_Click(object sender, EventArgs e)
        {
            lblMsg.Visible = false;
            pnlModalMsg.Visible = false;

            string sponsor = txtModalSponsor.Text.Trim();
            string uname = txtModalUname.Text.Trim();
            string fullName = txtModalFullName.Text.Trim();
            string email = txtModalEmail.Text.Trim();
            string mobile = txtModalMobile.Text.Trim();
            string pass = txtModalPass.Text.Trim();

            if (string.IsNullOrEmpty(sponsor) || string.IsNullOrEmpty(uname) || string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(mobile) || string.IsNullOrEmpty(pass))
            {
                ShowModalMsg("alert-danger", "Please fill all mandatory fields (Username, Full Name, Mobile, Password).");
                return;
            }

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    
                    // 1. Uniqueness verification for Username
                    SqlCommand cmdU = new SqlCommand("SELECT COUNT(*) FROM Users WHERE Username = @u", con);
                    cmdU.Parameters.AddWithValue("@u", uname);
                    if ((int)cmdU.ExecuteScalar() > 0) { ShowModalMsg("alert-danger", "This username is already allocated to another account."); return; }

                    // 2. Uniqueness verification for Mobile
                    SqlCommand cmdM = new SqlCommand("SELECT COUNT(*) FROM Users WHERE Mobile = @m", con);
                    cmdM.Parameters.AddWithValue("@m", mobile);
                    if ((int)cmdM.ExecuteScalar() > 0) { ShowModalMsg("alert-danger", "Mobile number already linked with an existing portfolio."); return; }

                    // 3. Lookup parent's real name
                    SqlCommand cmdSp = new SqlCommand("SELECT FullName FROM Users WHERE Username = @sp", con);
                    cmdSp.Parameters.AddWithValue("@sp", sponsor);
                    object spRes = cmdSp.ExecuteScalar();
                    string sponsorRealName = spRes != null ? spRes.ToString() : "";

                    // 4. Invoke our standard Stored Procedure with full Automated Placement Spillover Execution!
                    using (SqlCommand cmdIns = new SqlCommand("sp_UserSignup", con))
                    {
                        cmdIns.CommandType = CommandType.StoredProcedure;
                        cmdIns.Parameters.AddWithValue("@SponsorId", sponsor);
                        cmdIns.Parameters.AddWithValue("@SponsorName", sponsorRealName);
                        cmdIns.Parameters.AddWithValue("@FullName", fullName);
                        cmdIns.Parameters.AddWithValue("@Dob", DBNull.Value); // Admin quick-add doesn't ask for DOB
                        cmdIns.Parameters.AddWithValue("@Gender", "Unspecified");
                        cmdIns.Parameters.AddWithValue("@Email", string.IsNullOrEmpty(email) ? (object)DBNull.Value : email);
                        cmdIns.Parameters.AddWithValue("@Mobile", mobile);
                        cmdIns.Parameters.AddWithValue("@Username", uname);
                        cmdIns.Parameters.AddWithValue("@Password", pass);
                        cmdIns.Parameters.AddWithValue("@Position", string.IsNullOrEmpty(hfSelectedPosition.Value) ? "Left" : hfSelectedPosition.Value);

                        object result = cmdIns.ExecuteScalar();
                        if (result == null || Convert.ToInt32(result) == -1)
                        {
                            ShowModalMsg("alert-danger", "Enrollment failure: Username conflict or node space occupancy violation.");
                            return;
                        }
                        
                        // Automatically activate the account immediately for Admin-added members
                        SqlCommand cmdAct = new SqlCommand("UPDATE Users SET IsActive=1, IsEmailVerified=1, IsMobileVerified=1 WHERE Username=@u", con);
                        cmdAct.Parameters.AddWithValue("@u", uname);
                        cmdAct.ExecuteNonQuery();
                    }

                }

                // Trigger tree refresh instantly
                string rootToReload = txtSearchUser.Text.Trim();
                RenderAdminTree(rootToReload);

                // Flush form buffers
                txtModalUname.Text = ""; txtModalFullName.Text = ""; txtModalEmail.Text = ""; txtModalMobile.Text = ""; txtModalPass.Text = "";

                // Transmit operational success alerts
                lblMsg.Text = "🎉 Successfully enrolled '" + uname + "' directly under sponsor " + sponsor + "!";
                lblMsg.CssClass = "alert alert-success u-d-block u-mb-20";
                lblMsg.Visible = true;

                ScriptManager.RegisterStartupScript(this, GetType(), "CloseModal", "closeQuickRegModal();", true);
            }
            catch (Exception ex)
            {
                ShowModalMsg("alert-danger", "Registry Write Violation: " + ex.Message);
            }
        }

        private void ShowModalMsg(string css, string msg)
        {
            pnlModalMsg.CssClass = "alert " + css + " u-mb-15";
            lblModalMsg.Text = msg;
            pnlModalMsg.Visible = true;
            ScriptManager.RegisterStartupScript(this, GetType(), "KeepOpen", "document.getElementById('modal-quick-reg').classList.add('show');", true);
        }
    }
}
