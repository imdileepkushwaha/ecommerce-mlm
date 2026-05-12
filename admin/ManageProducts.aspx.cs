using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ecommerce_mlm.admin
{
    public partial class ManageProducts : Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadProducts();
            }
        }

        protected void rptProducts_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "ToggleStatus")
            {
                string pid = e.CommandArgument.ToString();
                try
                {
                    using (SqlConnection con = new SqlConnection(strcon))
                    {
                        con.Open();
                        string sql = "UPDATE SellerProducts SET IsActive = ~IsActive WHERE Id = @pid";
                        SqlCommand cmd = new SqlCommand(sql, con);
                        cmd.Parameters.AddWithValue("@pid", pid);
                        cmd.ExecuteNonQuery();
                    }
                    Response.Redirect("ManageProducts.aspx"); // Purge postback state to prevent re-toggle on refresh
                }
                catch (Exception ex) { }
            }
        }

        private void LoadProducts()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    string sql = @"SELECT Id, Name, Brand, Category, Price, Mrp, Stock, MainImage, IsActive, CreatedAt 
                                   FROM SellerProducts ORDER BY CreatedAt DESC";
                    SqlCommand cmd = new SqlCommand(sql, con);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        rptProducts.DataSource = dt;
                        rptProducts.DataBind();
                        rptProducts.Visible = true;
                        pnlEmpty.Visible = false;
                        lblCount.Text = "Count: " + dt.Rows.Count;
                    }
                    else
                    {
                        rptProducts.Visible = false;
                        pnlEmpty.Visible = true;
                        lblCount.Text = "0 Total";
                    }
                }
            }
            catch (Exception ex)
            {
                lblCount.Text = "ERR";
            }
        }
    }
}
