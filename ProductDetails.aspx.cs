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
    public partial class ProductDetails : System.Web.UI.Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;
        
        // Public vars for direct inline frontend rendering
        public string mainImageUrl = "https://via.placeholder.com/600?text=Product+Image";
        public decimal productRawPrice = 0;
        public int productId = 0;
        public int dynamicSoldCount = 145;

        protected void Page_Load(object sender, EventArgs e)
        {
            dynamicSoldCount = new Random().Next(60, 280);
            
            if (!IsPostBack)
            {
                string slug = Request.QueryString["slug"];
                if (string.IsNullOrEmpty(slug))
                {
                    Response.Redirect("ProductList.aspx");
                    return;
                }
                LoadProductBySlug(slug);
            }
        }

        private void LoadProductBySlug(string slug)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string q = "SELECT * FROM SellerProducts WHERE Slug = @slug";
                    using (SqlCommand cmd = new SqlCommand(q, con))
                    {
                        cmd.Parameters.AddWithValue("@slug", slug);
                        SqlDataReader dr = cmd.ExecuteReader();
                        if (dr.Read())
                        {
                            // Core details binding
                            productId = Convert.ToInt32(dr["Id"]);
                            string name = dr["Name"].ToString();
                            litName.Text = name;
                            litBTitle.Text = name;
                            // litBTitle2.Text = name;
                            
                            litPrice.Text = Convert.ToDecimal(dr["Price"]).ToString("N0");
                            productRawPrice = Convert.ToDecimal(dr["Price"]);
                            litActionPrice.Text = litPrice.Text; 
                            
                            decimal mrpVal = Convert.ToDecimal(dr["Mrp"]);
                            litMrp.Text = mrpVal.ToString("N0");

                            // Calculate Discount percentage for the new pill
                            if (mrpVal > productRawPrice && mrpVal > 0) {
                                decimal disc = ((mrpVal - productRawPrice) / mrpVal) * 100;
                                litDiscountPill.Text = "-" + Math.Round(disc).ToString() + "% OFF";
                                litDiscountPill.Visible = true;
                            } else { litDiscountPill.Visible = false; }

                            sBrand.Text = dr["Brand"].ToString();
                            litBrandDisplay.Text = sBrand.Text;
                            
                            string cat = dr["Category"].ToString();
                            sCat.Text = cat;

                            sSku.Text = dr["Sku"] != DBNull.Value ? dr["Sku"].ToString() : "N/A";

                            sGen.Text = dr["Gender"] != DBNull.Value ? dr["Gender"].ToString() : "Unisex";
                            sPType.Text = dr["ProductType"] != DBNull.Value ? dr["ProductType"].ToString() : "Fashion";
                            sWeight.Text = dr["Weight"] != DBNull.Value ? dr["Weight"].ToString() + " kg" : "Standard";
                            sDim.Text = dr["Dimensions"] != DBNull.Value ? dr["Dimensions"].ToString() : "Standard";

                            // Seller Offers with fallback
                            string offer1 = dr["FlashOffer"] != DBNull.Value ? dr["FlashOffer"].ToString() : "";
                            litOffer1.Text = !string.IsNullOrEmpty(offer1) ? offer1 : "Get 10% Instant Cash back on using Paytm.";
                            
                            string offer2 = dr["BankOffer"] != DBNull.Value ? dr["BankOffer"].ToString() : "";
                            litOffer2.Text = !string.IsNullOrEmpty(offer2) ? offer2 : "FLAT ₹100 OFF on your first valid digital order.";

                            litFullDesc.Text = dr["Description"].ToString();
                            
                            // Badge fallback
                            litBadge.Text = dr["BadgeText"] != DBNull.Value && !string.IsNullOrEmpty(dr["BadgeText"].ToString()) 
                                ? dr["BadgeText"].ToString() : "Premium Choice";

                            // Main image fallback
                            if (dr["MainImage"] != DBNull.Value && !string.IsNullOrEmpty(dr["MainImage"].ToString()))
                                mainImageUrl = dr["MainImage"].ToString();

                            // Size/Color dynamic lists
                            BindOptionList(dr["SizeOptions"], rptSizes, pnlSizes);
                            BindOptionList(dr["ColorOptions"], rptColors, pnlColors);

                            // Gallery logic
                            string gStr = dr["GalleryUrls"] != DBNull.Value ? dr["GalleryUrls"].ToString() : "";
                            if (!string.IsNullOrEmpty(gStr))
                            {
                                var images = gStr.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries).ToList();
                                rptGallery.DataSource = images;
                                rptGallery.DataBind();
                            }

                            dr.Close(); 
                            LoadReviews(productId); // Call new review function
                            LoadRelatedProducts(cat, productId);
                        }
                        else
                        {
                            dr.Close();
                            Response.Redirect("ProductList.aspx"); 
                        }
                    }
                }
            }
            catch(Exception ex) {
                Response.Write("<script>console.error('" + ex.Message + "');</script>");
            }
        }

        private void LoadReviews(int pid)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    string q = "SELECT * FROM ProductReviews WHERE ProductId = @pid ORDER BY ReviewDate DESC";
                    using (SqlCommand cmd = new SqlCommand(q, con))
                    {
                        cmd.Parameters.AddWithValue("@pid", pid);
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        int count = dt.Rows.Count;
                        litRevCountTab.Text = "(" + count + ")";
                        litRevCountSummary.Text = count + " Reviews";
                        litMainRevCount.Text = "(" + count + " Reviews)";

                        if (count > 0)
                        {
                            rptReviews.DataSource = dt;
                            rptReviews.DataBind();
                            rptReviews.Visible = true;
                            pnlNoReviews.Visible = false;
                        }
                        else
                        {
                            rptReviews.Visible = false;
                            pnlNoReviews.Visible = true;
                        }
                    }
                }
            }
            catch { }
        }

        protected string RenderRevStars(object ratingObj)
        {
            int rating = ratingObj != DBNull.Value ? Convert.ToInt32(ratingObj) : 5;
            string html = "";
            for(int i=1; i<=5; i++) {
                if(i <= rating) html += "<i class='fas fa-star'></i>";
                else html += "<i class='far fa-star'></i>";
            }
            return html;
        }

        private void BindOptionList(object rawData, Repeater rpt, Panel pnl)
        {
            if (rawData != DBNull.Value && !string.IsNullOrEmpty(rawData.ToString()))
            {
                string content = rawData.ToString();
                var items = content.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                                    .Select(s => s.Trim()).ToList();
                if (items.Count > 0)
                {
                    rpt.DataSource = items;
                    rpt.DataBind();
                    pnl.Visible = true;
                }
                else pnl.Visible = false;
            }
            else pnl.Visible = false;
        }

        private void LoadRelatedProducts(string category, int currentId)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    string q = "SELECT TOP 4 * FROM SellerProducts WHERE Category = @cat AND Id != @curId ORDER BY NEWID()";
                    using (SqlCommand cmd = new SqlCommand(q, con))
                    {
                        cmd.Parameters.AddWithValue("@cat", category);
                        cmd.Parameters.AddWithValue("@curId", currentId);
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        rptRelated.DataSource = dt;
                        rptRelated.DataBind();
                    }
                }
            }
            catch { }
        }
    }
}
