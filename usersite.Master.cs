using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ecommerce_mlm
{
    public partial class usersite : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
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

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}
