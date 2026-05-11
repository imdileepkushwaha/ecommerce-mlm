using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ecommerce_mlm
{
    public partial class index : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindFeaturedProducts();
            }
        }

        private void BindFeaturedProducts()
        {
            string connectionString = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_GetFeaturedProducts", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    try
                    {
                        con.Open();
                        DataTable dt = new DataTable();
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            da.Fill(dt);
                        }
                        rptFeaturedProducts.DataSource = dt;
                        rptFeaturedProducts.DataBind();
                    }
                    catch (Exception ex)
                    {
                        // Handle error silently or log it
                    }
                }
            }
        }
        protected string GetDiscountPercentage(object price, object mrp)
        {
            try
            {
                if (price == DBNull.Value || mrp == DBNull.Value) return "";
                decimal dPrice = Convert.ToDecimal(price);
                decimal dMrp = Convert.ToDecimal(mrp);
                if (dMrp > dPrice && dMrp > 0)
                {
                    decimal disc = ((dMrp - dPrice) / dMrp) * 100;
                    return Math.Round(disc).ToString() + "% OFF";
                }
            }
            catch { }
            return "";
        }
    }
}
