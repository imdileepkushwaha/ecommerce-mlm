using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;

namespace ecommerce_mlm
{
    public partial class userTree : System.Web.UI.Page
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
                RenderTree(Session["Username"].ToString());
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            lblMsg.Text = "";
            string term = txtSearchUser.Text.Trim();
            if (string.IsNullOrEmpty(term))
            {
                lblMsg.Text = "Please enter a username.";
                return;
            }

            // Verify username exists
            if (!UserExists(term))
            {
                lblMsg.Text = "Target user not found.";
                return;
            }

            RenderTree(term);
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtSearchUser.Text = "";
            lblMsg.Text = "";
            RenderTree(Session["Username"].ToString());
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

        private void RenderTree(string targetRoot)
        {
            // 1. Fetch entire tree dataset in ONE database call via Stored Procedure
            DataTable dtFullTree = new DataTable();
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    SqlCommand cmd = new SqlCommand("sp_GetNetworkTree", con);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@RootUsername", targetRoot);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dtFullTree);
                }
            }
            catch { }

            StringBuilder sb = new StringBuilder();
            sb.Append("<ul>");
            
            // Build logic passes memory datatable so no further DB queries needed!
            sb.Append(BuildRecursiveNode(targetRoot, 1, dtFullTree));

            sb.Append("</ul>");
            litTreeOutput.Text = sb.ToString();
        }

        private string BuildRecursiveNode(string username, int level, DataTable dtSource)
        {
            if (level > 4) return "";

            bool isAvailableNode = (username == "AVAILABLE");
            bool isActive = false;
            string fullName = "-";
            string sponsor = "-";
            int teamCount = 0;

            // Find user in our PRE-FETCHED memory DataTable
            DataRow[] match = dtSource.Select(string.Format("Username = '{0}'", username.Replace("'", "''")));

            if (!isAvailableNode && match.Length > 0)
            {
                DataRow dr = match[0];
                isActive = Convert.ToBoolean(dr["IsActive"]);
                fullName = dr["FullName"].ToString();
                sponsor = dr["SponsorId"].ToString();
                teamCount = Convert.ToInt32(dr["DirectTeamCount"]);
            }
            else
            {
                isAvailableNode = true;
            }

            StringBuilder nodeHtml = new StringBuilder();
            nodeHtml.Append("<li>");

            if (isAvailableNode)
            {
                nodeHtml.AppendFormat(@"
                    <div class='tree-node node-empty'>
                        <div class='node-avatar'><i class='fas fa-plus-circle'></i></div>
                        <div class='node-name' style='color:#94a3b8;'>Open</div>
                        <div class='node-role'>{0}</div>
                    </div>", "Lvl " + level);
            }
            else
            {
                string statusClass = isActive ? "node-active" : "node-deactive";
                string icon = isActive ? "fa-user-check" : "fa-user-slash";

                nodeHtml.AppendFormat(@"
                    <div class='tree-node {0}'>
                        <div class='node-avatar'><i class='fas {1}'></i></div>
                        <div class='node-name'>{2}</div>
                        <div class='node-role'>{3}</div>
                        <div class='node-tooltip'>
                            <div style='border-bottom:1px solid rgba(255,255,255,0.1); padding-bottom:8px; margin-bottom:8px; font-weight:700; color:#fff;'>User Overview</div>
                            <table class='tip-tbl'>
                                <tr><th>Name:</th><td>{4}</td></tr>
                                <tr><th>Username:</th><td>{2}</td></tr>
                                <tr><th>Sponsor:</th><td>{5}</td></tr>
                                <tr><th>Directs:</th><td>{6}</td></tr>
                                <tr><th>Status:</th><td>{7}</td></tr>
                            </table>
                        </div>
                    </div>", 
                    statusClass, icon, username, "Lvl " + level, 
                    fullName, sponsor, teamCount, 
                    (isActive ? "<span style='color:#4ade80;'>Active</span>" : "<span style='color:#f87171;'>Inactive</span>")
                );
            }

            if (level < 4)
            {
                string leftChild = "AVAILABLE";
                string rightChild = "AVAILABLE";

                if (!isAvailableNode)
                {
                    // Fetch dynamic direct children belonging to this parent FROM MEMORY TABLE
                    // Proc already delivered records ordered by CreatedAt!
                    // Exclude cases where username equals SponsorId to break recursive infinite loops 
                    DataRow[] children = dtSource.Select(string.Format("SponsorId = '{0}' AND Username <> '{0}'", username.Replace("'", "''")), "CreatedAt ASC");
                    
                    if (children.Length > 0) leftChild = children[0]["Username"].ToString();
                    if (children.Length > 1) rightChild = children[1]["Username"].ToString();
                }

                nodeHtml.Append("<ul>");
                nodeHtml.Append(BuildRecursiveNode(leftChild, level + 1, dtSource));
                nodeHtml.Append(BuildRecursiveNode(rightChild, level + 1, dtSource));
                nodeHtml.Append("</ul>");
            }

            nodeHtml.Append("</li>");
            return nodeHtml.ToString();
        }
    }
}
