using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ecommerce_mlm.admin
{
    public partial class ManageSellers : System.Web.UI.Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadSellers();
            }
        }

        private void LoadSellers()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    string query = "SELECT * FROM SellerUsers ORDER BY CreatedAt DESC";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        
                        rptSellers.DataSource = dt;
                        rptSellers.DataBind();
                        lblCount.Text = "Total: " + dt.Rows.Count;
                    }
                }
            }
            catch (Exception ex) 
            {
                lblCount.Text = "Fault: " + ex.Message;
            }
        }

        protected void rptSellers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string sellerId = e.CommandArgument.ToString();
            if (e.CommandName == "ToggleStatus")
            {
                try
                {
                    using (SqlConnection con = new SqlConnection(strcon))
                    {
                        con.Open();
                        string checkSql = "SELECT IsActive FROM SellerUsers WHERE Id = @id";
                        SqlCommand chk = new SqlCommand(checkSql, con);
                        chk.Parameters.AddWithValue("@id", sellerId);
                        bool current = Convert.ToBoolean(chk.ExecuteScalar());

                        string updateSql = "UPDATE SellerUsers SET IsActive = @newVal WHERE Id = @id";
                        SqlCommand cmd = new SqlCommand(updateSql, con);
                        cmd.Parameters.AddWithValue("@newVal", !current);
                        cmd.Parameters.AddWithValue("@id", sellerId);
                        cmd.ExecuteNonQuery();
                    }
                }
                catch { }
                
                // Post-Redirect-Get pattern ensures no double postbacks
                Response.Redirect("ManageSellers.aspx");
            }
        }
    }
}
