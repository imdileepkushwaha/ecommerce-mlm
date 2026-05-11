using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace ecommerce_mlm
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["Username"] != null)
            {
                Response.Redirect("Index.aspx");
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text.Trim();

            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
            {
                lblError.Text = "Please enter both Username and Password.";
                lblError.Visible = true;
                return;
            }

            string connStr = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;
            
            using (SqlConnection con = new SqlConnection(connStr))
            {
                using (SqlCommand cmd = new SqlCommand("sp_UserLogin", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Username", username);
                    cmd.Parameters.AddWithValue("@Password", password);

                    try
                    {
                        con.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.HasRows)
                            {
                                reader.Read();
                                Session["UserId"] = reader["Id"].ToString();
                                Session["Username"] = reader["Username"].ToString();
                                Session["FullName"] = reader["FullName"].ToString();

                                Response.Redirect("Index.aspx");
                            }
                            else
                            {
                                lblError.Text = "Invalid Username or Password.";
                                lblError.Visible = true;
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        lblError.Text = "An error occurred: " + ex.Message;
                        lblError.Visible = true;
                    }
                }
            }
        }
    }
}
