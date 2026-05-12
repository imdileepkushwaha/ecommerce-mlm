using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Configuration;

namespace ecommerce_mlm
{
    public partial class usersite : System.Web.UI.MasterPage
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Force-Lock session stability
            if (Session["InitSession"] == null) {
                Session["InitSession"] = DateTime.Now.ToString();
            }

            if (!IsPostBack)
            {
                LoadHeaderCounts();
                if (Session["Username"] != null)
                {
                    pnlLoggedIn.Visible = true;
                    pnlLoggedOut.Visible = false;
                    lblUsername.Text = Session["Username"].ToString();
                }
                else
                {
                    pnlLoggedIn.Visible = false;
                    pnlLoggedOut.Visible = true;
                }
            }
        }

        private void LoadHeaderCounts()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    // 1. Cart Count
                    string qCart = "SELECT ISNULL(SUM(Quantity), 0) FROM CartItems WHERE SessionId = @sid AND IsSavedForLater = 0";
                    using (SqlCommand cmd = new SqlCommand(qCart, con)) {
                        cmd.Parameters.AddWithValue("@sid", Session.SessionID);
                        cart_count.Text = cmd.ExecuteScalar().ToString();
                    }
                    // 2. Wishlist Count
                    string qWish = "SELECT COUNT(*) FROM WishlistItems WHERE SessionId = @sid";
                    using (SqlCommand cmd = new SqlCommand(qWish, con)) {
                        cmd.Parameters.AddWithValue("@sid", Session.SessionID);
                        wishlist_count.Text = cmd.ExecuteScalar().ToString();
                    }
                }
            }
            catch { 
                cart_count.Text = "0";
                wishlist_count.Text = "0";
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}
