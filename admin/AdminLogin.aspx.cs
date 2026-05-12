using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace ecommerce_mlm.admin
{
    public partial class AdminLogin : Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                pnlAlert.Visible = false;
                pnlAlert.CssClass = "alert-msg";
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string email = txtEmail.Text.Trim();
            string pass = txtPassword.Text.Trim();

            if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(pass))
            {
                ShowError("Missing access parameters.");
                return;
            }

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    SqlCommand cmd = new SqlCommand("sp_AdminLogin", con);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Email", email);
                    cmd.Parameters.AddWithValue("@Password", pass);

                    SqlDataReader dr = cmd.ExecuteReader();
                    if (dr.HasRows)
                    {
                        dr.Read();
                        // Authenticate Sequence
                        Session["AdminId"] = dr["Id"].ToString();
                        Session["AdminEmail"] = dr["Email"].ToString();
                        Session["AdminName"] = dr["FullName"].ToString();
                        Session["Role"] = "Admin";

                        // Transfer control to command bridge
                        Response.Redirect("AdminDashboard.aspx", false);
                        Context.ApplicationInstance.CompleteRequest();
                    }
                    else
                    {
                        ShowError("Unauthorized identity variables detected.");
                    }
                }
            }
            catch (Exception ex)
            {
                ShowError("System fault during resolution: " + ex.Message);
            }
        }

        private void ShowError(string msg)
        {
            lblError.Text = msg;
            pnlAlert.Visible = true;
            pnlAlert.CssClass = "alert-msg visible";
        }
    }
}
