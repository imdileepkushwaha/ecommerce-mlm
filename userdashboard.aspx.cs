using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI;

namespace ecommerce_mlm
{
    public partial class userdashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // 1. Force authentication check - redirect back if no session active
            if (Session["Username"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadUserDetails();
            }
        }

        private void LoadUserDetails()
        {
            string username = Session["Username"].ToString();
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
                                string email = reader["Email"].ToString();
                                string profileImage = reader["ProfileImage"] != DBNull.Value ? reader["ProfileImage"].ToString() : "";

                                // Bind text fields
                                litUserName.Text = fullName;
                                litWelcomeName.Text = fullName;
                                litUserEmail.Text = email;

                                // Bind Profile Picture or Initials logic
                                bool imageExists = false;
                                string mappedPath = "";
                                try
                                {
                                    if (!string.IsNullOrWhiteSpace(profileImage))
                                    {
                                        mappedPath = Server.MapPath(profileImage);
                                        imageExists = System.IO.File.Exists(mappedPath);
                                    }
                                }
                                catch { imageExists = false; }

                                if (imageExists)
                                {
                                    litUserAvatar.Text = string.Format("<img src=\"{0}\" alt=\"Profile Pic\" />", ResolveUrl(profileImage));
                                }
                                else
                                {
                                    string initials = GetInitials(fullName);
                                    litUserAvatar.Text = string.Format("<div class=\"avatar-initials\">{0}</div>", initials);
                                }
                            }
                        }
                    }
                    catch (Exception)
                    {
                        litUserName.Text = Session["FullName"] != null ? Session["FullName"].ToString() : username;
                        litWelcomeName.Text = litUserName.Text;
                        litUserEmail.Text = "System Loaded";
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

            if (words.Length == 1)
            {
                return words[0].Length > 1 ? words[0].Substring(0, 2).ToUpper() : words[0][0].ToString().ToUpper();
            }

            // Return first character of first and last word
            return (words[0][0].ToString() + words[words.Length - 1][0].ToString()).ToUpper();
        }

        protected void btnLogoutDash_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("index.aspx");
        }
    }
}
