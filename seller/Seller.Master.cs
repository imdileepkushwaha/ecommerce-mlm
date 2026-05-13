using System;
using System.Web;
using System.Web.UI;

namespace EcommerceWebsite
{
    public partial class SellerMaster : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Security Gate: Pre-verify merchant session integrity
            if (Session["SellerId"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                // Dynamically Bind global Header variables
                string name = Session["SellerName"] != null ? Session["SellerName"].ToString() : "Merchant";
                litWelcomeName.Text = name;
                litAvatarLetter.Text = string.IsNullOrEmpty(name) ? "M" : name.Substring(0, 1).ToUpper();
                litSellerEmail.Text = Session["SellerEmail"] != null ? Session["SellerEmail"].ToString() : "";
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            // Purge Session Vectors
            Session.Remove("SellerId");
            Session.Remove("SellerName");
            Session.Remove("SellerEmail");
            
            Response.Redirect("Login.aspx");
        }
    }
}
