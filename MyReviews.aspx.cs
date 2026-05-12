using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ecommerce_mlm
{
    public partial class MyReviews : System.Web.UI.Page
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
                LoadUserDeliveredProducts();
            }
        }

        private int GetUserId()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    SqlCommand cmd = new SqlCommand("SELECT Id FROM Users WHERE Username = @u", con);
                    cmd.Parameters.AddWithValue("@u", Session["Username"].ToString());
                    object obj = cmd.ExecuteScalar();
                    return obj != null ? Convert.ToInt32(obj) : 0;
                }
            }
            catch { return 0; }
        }

        private string GetFullName()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    SqlCommand cmd = new SqlCommand("SELECT FullName FROM Users WHERE Username = @u", con);
                    cmd.Parameters.AddWithValue("@u", Session["Username"].ToString());
                    object obj = cmd.ExecuteScalar();
                    return obj != null ? obj.ToString() : Session["Username"].ToString();
                }
            }
            catch { return "Customer"; }
        }

        private void LoadUserDeliveredProducts()
        {
            int uId = GetUserId();
            if (uId == 0) return;

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    // Fetch unique delivered products user purchased and check for existing review
                    string q = @"
                        SELECT DISTINCT 
                            P.Id AS ProductId, 
                            P.Name AS ProductName, 
                            P.MainImage,
                            PR.Rating, 
                            PR.ReviewText, 
                            PR.ReviewDate,
                            CASE WHEN PR.Id IS NOT NULL THEN 1 ELSE 0 END AS HasReviewed
                        FROM Orders O
                        JOIN OrderItems OI ON O.Id = OI.OrderId
                        JOIN SellerProducts P ON OI.ProductId = P.Id
                        LEFT JOIN ProductReviews PR ON P.Id = PR.ProductId AND PR.UserId = @uid
                        WHERE O.UserId = @uid AND UPPER(O.Status) = 'DELIVERED'
                        ORDER BY HasReviewed ASC";
                    
                    SqlCommand cmd = new SqlCommand(q, con);
                    cmd.Parameters.AddWithValue("@uid", uId);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        rptDeliveredProducts.DataSource = dt;
                        rptDeliveredProducts.DataBind();
                        rptDeliveredProducts.Visible = true;
                        pnlNoProducts.Visible = false;
                    }
                    else
                    {
                        rptDeliveredProducts.Visible = false;
                        pnlNoProducts.Visible = true;
                    }
                }
            }
            catch (Exception ex) { 
                // Logging omitted 
            }
        }

        protected void rptDeliveredProducts_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "TriggerReview")
            {
                string[] args = e.CommandArgument.ToString().Split('|');
                if (args.Length >= 2)
                {
                    hfRevProdId.Value = args[0];
                    lblModalProdName.Text = args[1];
                    
                    // Reset form
                    hfRatingValue.Value = "0";
                    txtReviewText.Text = "";
                    lblModalErr.Text = "";

                    pnlReviewModal.Visible = true;
                    pnlReviewModal.CssClass = "modal-overlay active";
                    ScriptManager.RegisterStartupScript(this, GetType(), "ShowReview", "setTimeout(showModal, 10);", true);
                }
            }
        }

        protected void btnCloseModal_Click(object sender, EventArgs e)
        {
            pnlReviewModal.Visible = false;
        }

        protected void btnSubmitReview_Click(object sender, EventArgs e)
        {
            int ratingVal = 0;
            int.TryParse(hfRatingValue.Value, out ratingVal);

            if (ratingVal < 1 || ratingVal > 5)
            {
                lblModalErr.Text = "Please select a star rating (1-5).";
                return;
            }
            
            if (string.IsNullOrWhiteSpace(txtReviewText.Text))
            {
                lblModalErr.Text = "Please share a brief comment.";
                return;
            }

            int uId = GetUserId();
            string reviewerName = GetFullName();

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string q = @"INSERT INTO ProductReviews (ProductId, UserId, ReviewerName, Rating, ReviewText, ReviewDate, IsApproved, ReviewStatus, IsVerifiedPurchase, ProductName)
                                 VALUES (@pid, @uid, @rn, @r, @txt, GETDATE(), 1, 'APPROVED', 1, @pn)";
                    
                    SqlCommand cmd = new SqlCommand(q, con);
                    cmd.Parameters.AddWithValue("@pid", hfRevProdId.Value);
                    cmd.Parameters.AddWithValue("@uid", uId);
                    cmd.Parameters.AddWithValue("@rn", reviewerName);
                    cmd.Parameters.AddWithValue("@r", ratingVal);
                    cmd.Parameters.AddWithValue("@txt", txtReviewText.Text.Trim());
                    cmd.Parameters.AddWithValue("@pn", lblModalProdName.Text);

                    cmd.ExecuteNonQuery();
                }

                pnlReviewModal.Visible = false;
                LoadUserDeliveredProducts();
                ScriptManager.RegisterStartupScript(this, GetType(), "Success", "alert('Thank you! Your review was submitted.');", true);
            }
            catch (Exception ex)
            {
                lblModalErr.Text = "System constraint: could not save review.";
            }
        }

        // STATIC HELPER CALLED DIRECTLY FROM ASPX
        public static string GetStarsHTML(int rating)
        {
            StringBuilder sb = new StringBuilder();
            for (int i = 1; i <= 5; i++)
            {
                if (i <= rating)
                {
                    sb.Append("<i class=\"fas fa-star\" style=\"margin-right:2px;\"></i>");
                }
                else
                {
                    sb.Append("<i class=\"far fa-star\" style=\"color:#cbd5e1; margin-right:2px;\"></i>");
                }
            }
            return sb.ToString();
        }
    }
}
