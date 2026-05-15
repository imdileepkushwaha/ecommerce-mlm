using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web;
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
                BindProductsForReview();
            }
        }

        private int GetCurrentUserId()
        {
            if (Session["Username"] == null) return 0;
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    using (SqlCommand cmd = new SqlCommand("SELECT Id FROM Users WHERE Username = @uname", con))
                    {
                        cmd.Parameters.AddWithValue("@uname", Session["Username"].ToString());
                        object obj = cmd.ExecuteScalar();
                        return obj != null ? Convert.ToInt32(obj) : 0;
                    }
                }
            }
            catch { return 0; }
        }

        private string GetCurrentUserFullName()
        {
            if (Session["Username"] == null) return "Verified Buyer";
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    using (SqlCommand cmd = new SqlCommand("SELECT FullName FROM Users WHERE Username = @uname", con))
                    {
                        cmd.Parameters.AddWithValue("@uname", Session["Username"].ToString());
                        object obj = cmd.ExecuteScalar();
                        return obj != null && !string.IsNullOrEmpty(obj.ToString()) ? obj.ToString() : "Verified Buyer";
                    }
                }
            }
            catch { return "Verified Buyer"; }
        }

        private void BindProductsForReview()
        {
            int userId = GetCurrentUserId();
            if (userId == 0) return;

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    // Modified to match screenshot schema: shows products ordered by user, joined with reviews
                    // Uses DISTINCT/GROUP based approach for product-level reviews
                    string sql = @"
                        SELECT 
                            P.Id AS ProductId,
                            P.Name AS ProductName,
                            P.MainImage,
                            MAX(O.CreatedAt) AS CreatedAt,
                            MAX(PR.Rating) AS Rating,
                            MAX(PR.ReviewText) AS ReviewText,
                            MAX(PR.ReviewStatus) AS ReviewStatus,
                            CASE WHEN MAX(PR.Id) IS NOT NULL THEN 1 ELSE 0 END AS HasReviewed
                        FROM Orders O
                        INNER JOIN OrderItems OI ON O.Id = OI.OrderId
                        INNER JOIN SellerProducts P ON OI.ProductId = P.Id
                        LEFT JOIN ProductReviews PR ON P.Id = PR.ProductId AND PR.UserId = @uid
                        WHERE O.UserId = @uid AND UPPER(O.Status) = 'DELIVERED'
                        GROUP BY P.Id, P.Name, P.MainImage
                        ORDER BY HasReviewed ASC, CreatedAt DESC";

                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@uid", userId);
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            DataTable dt = new DataTable();
                            da.Fill(dt);

                            if (dt.Rows.Count > 0)
                            {
                                rptProductReviews.DataSource = dt;
                                rptProductReviews.DataBind();
                                rptProductReviews.Visible = true;
                                pnlEmpty.Visible = false;
                            }
                            else
                            {
                                rptProductReviews.Visible = false;
                                pnlEmpty.Visible = true;
                            }
                        }
                    }
                }
            }
            catch
            {
                pnlEmpty.Visible = true;
            }
        }

        protected void rptProductReviews_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "ExpandForm")
            {
                // Expand the inline writing form for the specific item
                ViewState["ActiveWriteProductId"] = e.CommandArgument.ToString();
                BindProductsForReview();
            }
            else if (e.CommandName == "SubmitReview")
            {
                int productId = Convert.ToInt32(e.CommandArgument);
                
                // Locate controls inside RepeaterItem
                DropDownList ddlStars = (DropDownList)e.Item.FindControl("ddlStars");
                TextBox txtComment = (TextBox)e.Item.FindControl("txtInlineComment");
                Label lblErr = (Label)e.Item.FindControl("lblInlineError");

                int rating = Convert.ToInt32(ddlStars.SelectedValue);
                string comment = txtComment.Text.Trim();

                if (string.IsNullOrEmpty(comment))
                {
                    lblErr.Text = "Please provide some feedback.";
                    lblErr.Visible = true;
                    return;
                }

                // Perform database insertion
                int userId = GetCurrentUserId();
                string fullName = GetCurrentUserFullName();
                
                if (userId == 0)
                {
                    lblErr.Text = "Session expired. Please login again.";
                    lblErr.Visible = true;
                    return;
                }

                try
                {
                    using (SqlConnection con = new SqlConnection(strcon))
                    {
                        con.Open();

                        // Fetch real name from SellerProducts to ensure ProductName mapping is solid
                        string dbProductName = "Product";
                        using (SqlCommand pnameCmd = new SqlCommand("SELECT Name FROM SellerProducts WHERE Id = @pid", con))
                        {
                            pnameCmd.Parameters.AddWithValue("@pid", productId);
                            object o = pnameCmd.ExecuteScalar();
                            if (o != null) dbProductName = o.ToString();
                        }

                        // Set ReviewStatus to PENDING, IsApproved to 0 (Wait for Seller Approval)
                        string insertSql = @"
                            INSERT INTO ProductReviews (
                                ProductId, UserId, ReviewerName, Rating, ReviewText, 
                                ReviewDate, IsApproved, ReviewStatus, IsVerifiedPurchase, ProductName
                            ) VALUES (
                                @pid, @uid, @rname, @rating, @rtext, 
                                GETDATE(), 0, 'PENDING', 1, @pname
                            )";

                        using (SqlCommand cmd = new SqlCommand(insertSql, con))
                        {
                            cmd.Parameters.AddWithValue("@pid", productId);
                            cmd.Parameters.AddWithValue("@uid", userId);
                            cmd.Parameters.AddWithValue("@rname", fullName);
                            cmd.Parameters.AddWithValue("@rating", rating);
                            cmd.Parameters.AddWithValue("@rtext", comment);
                            cmd.Parameters.AddWithValue("@pname", dbProductName);

                            cmd.ExecuteNonQuery();
                        }
                    }

                    // Success, clear expanded panel and refresh list
                    ViewState["ActiveWriteProductId"] = null;
                    BindProductsForReview();
                    
                    // Optional user alert toast
                    ScriptManager.RegisterStartupScript(this, GetType(), "ToastSuccess", "alert('Thank you for submitting! Your review is under process.');", true);
                }
                catch (Exception ex)
                {
                    lblErr.Text = "Save failed: " + ex.Message;
                    lblErr.Visible = true;
                }
            }
        }

        protected void rptProductReviews_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DataRowView row = (DataRowView)e.Item.DataItem;
                string prodId = row["ProductId"].ToString();

                Panel pnlWrite = (Panel)e.Item.FindControl("pnlInlineWriteReview");
                
                // Toggle expanding inline form based on saved dynamic view state
                if (ViewState["ActiveWriteProductId"] != null && ViewState["ActiveWriteProductId"].ToString() == prodId)
                {
                    pnlWrite.Visible = true;
                }
                else
                {
                    pnlWrite.Visible = false;
                }
            }
        }

        #region Formatting Helpers

        protected string ResolveProductImage(object imgObj)
        {
            if (imgObj == null || imgObj == DBNull.Value || string.IsNullOrEmpty(imgObj.ToString()))
            {
                return "assets/images/no-image.png";
            }

            string path = imgObj.ToString();
            if (path.StartsWith("http://", StringComparison.OrdinalIgnoreCase) || 
                path.StartsWith("https://", StringComparison.OrdinalIgnoreCase) || 
                path.StartsWith("//"))
            {
                return path;
            }

            // Cleans virtual directory path prefix 
            string relative = path.Replace("~", "");
            if (!relative.StartsWith("/")) relative = "/" + relative;

            return ResolveUrl("~" + relative);
        }

        protected string GetVisualStars(object ratingObj)
        {
            if (ratingObj == null || ratingObj == DBNull.Value) return "";
            int rating = Convert.ToInt32(ratingObj);

            StringBuilder sb = new StringBuilder();
            for (int i = 1; i <= 5; i++)
            {
                if (i <= rating)
                {
                    sb.Append("<i class=\"fas fa-star\"></i>");
                }
                else
                {
                    sb.Append("<i class=\"far fa-star\" style=\"color:#cbd5e1;\"></i>");
                }
            }
            return sb.ToString();
        }

        #endregion
    }
}
