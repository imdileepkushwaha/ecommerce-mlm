using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace ecommerce_mlm.admin
{
    public partial class ManageUsers : Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadUsers("");
            }
        }


        protected void rptUsers_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "ToggleStatus")
            {
                string userId = e.CommandArgument.ToString();
                try
                {
                    using (SqlConnection con = new SqlConnection(strcon))
                    {
                        con.Open();
                        // Atomic flip of bit
                        string sql = "UPDATE Users SET IsActive = ~IsActive WHERE Id = @id";
                        SqlCommand cmd = new SqlCommand(sql, con);
                        cmd.Parameters.AddWithValue("@id", userId);
                        cmd.ExecuteNonQuery();
                    }
                    Response.Redirect("ManageUsers.aspx"); // Prevent double flip on refresh
                }
                catch (Exception ex) { }
            }
        }

        private void LoadUsers(string query)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    string sql = "SELECT Id, FullName, Username, Email, Mobile, SponsorName, CreatedAt, IsActive FROM Users";
                    if (!string.IsNullOrEmpty(query))
                    {
                        sql += " WHERE FullName LIKE @q OR Email LIKE @q OR Username LIKE @q";
                    }
                    sql += " ORDER BY CreatedAt DESC";

                    SqlCommand cmd = new SqlCommand(sql, con);
                    if (!string.IsNullOrEmpty(query))
                    {
                        cmd.Parameters.AddWithValue("@q", "%" + query + "%");
                    }

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        rptUsers.DataSource = dt;
                        rptUsers.DataBind();
                        rptUsers.Visible = true;
                        pnlEmpty.Visible = false;
                        lblCount.Text = "Total Members: " + dt.Rows.Count;
                    }
                    else
                    {
                        rptUsers.Visible = false;
                        pnlEmpty.Visible = true;
                        lblCount.Text = "0 Results";
                    }
                }
            }
            catch (Exception ex)
            {
                // Handle silently or log
                lblCount.Text = "ERR";
            }
        }

        public string GetInitials(string name)
        {
            if (string.IsNullOrEmpty(name)) return "U";
            string[] parts = name.Trim().Split(' ');
            if (parts.Length >= 2)
            {
                return (parts[0][0].ToString() + parts[1][0].ToString()).ToUpper();
            }
            return name.Substring(0, Math.Min(name.Length, 2)).ToUpper();
        }
    }
}
