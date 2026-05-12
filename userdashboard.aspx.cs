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
                LoadWelcomeName();
            }
        }

        private void LoadWelcomeName()
        {
            string username = Session["Username"].ToString();
            string connStr = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;

            using (SqlConnection con = new SqlConnection(connStr))
            {
                string query = "SELECT FullName FROM Users WHERE Username = @Username";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Username", username);
                    try
                    {
                        con.Open();
                        object res = cmd.ExecuteScalar();
                        litWelcomeName.Text = res != null ? res.ToString() : username;
                    }
                    catch
                    {
                        litWelcomeName.Text = username;
                    }
                }
            }
        }
    }
}
