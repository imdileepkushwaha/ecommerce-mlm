using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ecommerce_mlm
{
    public partial class ProductList : System.Web.UI.Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadAllProducts();
            }
        }

        private void LoadAllProducts()
        {
            try
            {
                string sortOrder = "Id DESC"; // default
                string sortParam = Request.QueryString["sort"];
                
                if (!string.IsNullOrEmpty(sortParam)) {
                    if (sortParam == "low_high") sortOrder = "Price ASC";
                    else if (sortParam == "high_low") sortOrder = "Price DESC";
                }

                string searchQ = Request.QueryString["q"];
                
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    string q = "SELECT * FROM SellerProducts ";
                    
                    if (!string.IsNullOrEmpty(searchQ)) {
                        q += " WHERE (Name LIKE @search OR Brand LIKE @search OR Category LIKE @search) ";
                    }

                    q += " ORDER BY " + sortOrder;
                    
                    using (SqlCommand cmd = new SqlCommand(q, con))
                    {
                        if (!string.IsNullOrEmpty(searchQ)) {
                            cmd.Parameters.AddWithValue("@search", "%" + searchQ + "%");
                        }

                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            rptProducts.DataSource = dt;
                            rptProducts.DataBind();
                            litTotalCount.Text = dt.Rows.Count.ToString();
                            pnlNoData.Visible = false;
                        }
                        else
                        {
                            rptProducts.Visible = false;
                            pnlNoData.Visible = true;
                            litTotalCount.Text = "0";
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Response.Write("<script>console.error('DB Load Fail: " + ex.Message + "');</script>");
            }
        }

        protected string GetDiscountPercentage(object price, object mrp)
        {
            try
            {
                if (price != null && mrp != null && price != DBNull.Value && mrp != DBNull.Value)
                {
                            decimal p = Convert.ToDecimal(price);
                            decimal m = Convert.ToDecimal(mrp);
                            if (m > 0 && m > p)
                            {
                                decimal discount = ((m - p) / m) * 100;
                                return Math.Round(discount).ToString() + "%";
                            }
                }
                return "0%";
            }
            catch { return "0%"; }
        }
    }
}
