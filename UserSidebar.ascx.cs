using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web;

namespace ecommerce_mlm
{
    public partial class UserSidebar : System.Web.UI.UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadUserDetails();
            }
        }

        private void LoadUserDetails()
        {
            string username = Session["Username"] != null ? Session["Username"].ToString() : "";
            if (string.IsNullOrEmpty(username))
            {
                litUserName.Text = "Guest User";
                litUserEmail.Text = "Save items for later!";
                litUserAvatar.Text = "<div class=\"avatar-initials\">G</div>";
                return;
            }

            string connStr = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string query = "SELECT FullName, Email, ProfileImage FROM Users WHERE Username = @Username";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Username", username);
                    try
                    {
                        con.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string fullName = reader["FullName"].ToString();
                                litUserName.Text = fullName;
                                litUserEmail.Text = reader["Email"].ToString();

                                string profileImage = reader["ProfileImage"] != DBNull.Value ? reader["ProfileImage"].ToString() : "";
                                bool exists = false;
                                try { if (!string.IsNullOrWhiteSpace(profileImage)) exists = System.IO.File.Exists(Server.MapPath(profileImage)); } catch { }

                                if (exists)
                                    litUserAvatar.Text = string.Format("<img src=\"{0}\" alt=\"Avatar\" />", ResolveUrl(profileImage));
                                else
                                    litUserAvatar.Text = string.Format("<div class=\"avatar-initials\">{0}</div>", GetInitials(fullName));
                            }
                        }
                    }
                    catch
                    {
                        litUserName.Text = Session["FullName"] != null ? Session["FullName"].ToString() : username;
                        litUserEmail.Text = username;
                        litUserAvatar.Text = string.Format("<div class=\"avatar-initials\">{0}</div>", GetInitials(litUserName.Text));
                    }
                }
            }
        }

        private string GetInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "U";
            var words = name.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (words.Length == 0) return "U";
            if (words.Length == 1) return words[0].Length > 1 ? words[0].Substring(0, 2).ToUpper() : words[0][0].ToString().ToUpper();
            return (words[0][0].ToString() + words[words.Length - 1][0].ToString()).ToUpper();
        }

        protected void btnLogoutDash_Click(object sender, EventArgs e)
        {
            Session.Clear(); Session.Abandon();
            Response.Redirect("index.aspx");
        }

        public string GetActiveClass(string targetPage)
        {
            string currentPage = Request.Url.Segments[Request.Url.Segments.Length - 1].ToLower();
            return currentPage == targetPage.ToLower() ? "active" : "";
        }
    }
}
