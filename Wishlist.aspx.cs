using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace ecommerce_mlm
{
    public partial class Wishlist : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadWishlist();
            }
        }

        private void LoadWishlist()
        {
            try
            {
                string conStr = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;
                string sid = Session.SessionID;

                using (SqlConnection con = new SqlConnection(conStr))
                {
                    // Basic join with product and fallback category retrieval logic
                    string query = @"
                        SELECT w.ProductId, p.Name, p.Price, p.Mrp, p.MainImage, ISNULL(p.Category, 'FASHION') AS CategoryName
                        FROM WishlistItems w
                        INNER JOIN SellerProducts p ON w.ProductId = p.Id
                        WHERE w.SessionId = @sid
                        ORDER BY w.AddedDate DESC";

                    SqlCommand cmd = new SqlCommand(query, con);
                    cmd.Parameters.AddWithValue("@sid", sid);

                    DataTable dt = new DataTable();
                    SqlDataAdapter sda = new SqlDataAdapter(cmd);
                    con.Open();
                    sda.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        rptWishlist.DataSource = dt;
                        rptWishlist.DataBind();
                        litWishCount.Text = dt.Rows.Count.ToString();
                        pnlEmpty.Visible = false;
                    }
                    else
                    {
                        rptWishlist.DataSource = null;
                        rptWishlist.DataBind();
                        litWishCount.Text = "0";
                        pnlEmpty.Visible = true;
                    }
                }
            }
            catch (Exception ex)
            {
                litWishCount.Text = "ERR: " + ex.Message;
                pnlEmpty.Visible = true;
            }
        }
    }
}
