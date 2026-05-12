using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace ecommerce_mlm
{
    public partial class UserOrders : System.Web.UI.Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["Username"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadOrders();
            }
        }

        private void LoadOrders()
        {
            string username = Session["Username"].ToString().Trim();
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    // Using implicit INNER JOIN approach matching table users.Username
                    string q = @"SELECT O.Id, O.Status, O.TotalAmount, O.ItemCount, O.CreatedAt 
                                 FROM Orders O 
                                 INNER JOIN Users U ON O.UserId = U.Id 
                                 WHERE U.Username = @u 
                                 ORDER BY O.CreatedAt DESC";
                    
                    using (SqlCommand cmd = new SqlCommand(q, con))
                    {
                        cmd.Parameters.AddWithValue("@u", username);
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            rptOrders.DataSource = dt;
                            rptOrders.DataBind();
                            pnlNoOrders.Visible = false;
                        }
                        else
                        {
                            rptOrders.DataSource = null;
                            rptOrders.DataBind();
                            pnlNoOrders.Visible = true;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                // Handle gracefully, could bind an empty repeater or print response
                Response.Write("<script>console.error('Order Loading Error: " + ex.Message.Replace("'", "") + "');</script>");
                pnlNoOrders.Visible = true;
            }
        }
    }
}
