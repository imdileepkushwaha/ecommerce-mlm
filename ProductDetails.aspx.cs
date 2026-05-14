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
    public class SizeItem {
        public string Name { get; set; }
        public int Stock { get; set; }
    }

    public partial class ProductDetails : System.Web.UI.Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;
        
        // Public vars for direct inline frontend rendering
        public string mainImageUrl = "https://via.placeholder.com/600?text=Product+Image";
        public decimal productRawPrice = 0;
        public int productId = 0;
        public int productStock = 999;
        public int dynamicSoldCount = 145;
        public bool isAvailable = true;
        public bool isInWishlist = false;
        public int activeSellerId = 0;

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
                    string q = "SELECT P.*, S.IsActive AS SellerActive, S.StoreName, S.FullName AS SellerFullName FROM SellerProducts P INNER JOIN SellerUsers S ON P.SellerId = S.Id WHERE P.Slug = @slug";
                    using (SqlCommand cmd = new SqlCommand(q, con))
                    {
                        cmd.Parameters.AddWithValue("@slug", slug);
                        SqlDataReader dr = cmd.ExecuteReader();
                        if (dr.Read())
                        {
                            // Core details binding
                            productId = Convert.ToInt32(dr["Id"]);
                            string name = dr["Name"].ToString();
                            
                            // Aggregate Availability Logic (Product Active + Seller Active + Stock > 0)
                            bool active = dr["IsActive"] != DBNull.Value && Convert.ToBoolean(dr["IsActive"]);
                            bool sActive = dr["SellerActive"] != DBNull.Value && Convert.ToBoolean(dr["SellerActive"]);
                            int stk = dr["Stock"] != DBNull.Value ? Convert.ToInt32(dr["Stock"]) : 0;
                            isAvailable = active && sActive && stk > 0;
                            productStock = stk; // expose to JS
                            
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

                            activeSellerId = dr["SellerId"] != DBNull.Value ? Convert.ToInt32(dr["SellerId"]) : 0;
                            sBrand.Text = dr["Brand"].ToString();
                            
                            string storeName = dr["StoreName"] != DBNull.Value && !string.IsNullOrEmpty(dr["StoreName"].ToString()) 
                                ? dr["StoreName"].ToString() : (dr["SellerFullName"] != DBNull.Value ? dr["SellerFullName"].ToString() : sBrand.Text);
                            litBrandDisplay.Text = storeName;
                            
                            string cat = dr["Category"].ToString();
                            sCat.Text = cat;

                            sSku.Text = dr["Sku"] != DBNull.Value ? dr["Sku"].ToString() : "N/A";

                            sGen.Text = dr["Gender"] != DBNull.Value ? dr["Gender"].ToString() : "Unisex";
                            sPType.Text = dr["ProductType"] != DBNull.Value ? dr["ProductType"].ToString() : "Fashion";
                            sWeight.Text = dr["Weight"] != DBNull.Value ? dr["Weight"].ToString() + " kg" : "Standard";
                            sDim.Text = dr["Dimensions"] != DBNull.Value ? dr["Dimensions"].ToString() : "Standard";

                            // Manufacturer Data Bindings with premium fallbacks
                            litMfgName.Text = dr["ManufacturerName"] != DBNull.Value && !string.IsNullOrEmpty(dr["ManufacturerName"].ToString()) 
                                ? dr["ManufacturerName"].ToString() : "Refer to Packaging / Official Importer";
                            
                            litMfgCountry.Text = dr["ManufacturerCountry"] != DBNull.Value && !string.IsNullOrEmpty(dr["ManufacturerCountry"].ToString()) 
                                ? dr["ManufacturerCountry"].ToString() : "India";
                                
                            litMfgAddress.Text = dr["ManufacturerAddress"] != DBNull.Value && !string.IsNullOrEmpty(dr["ManufacturerAddress"].ToString()) 
                                ? dr["ManufacturerAddress"].ToString() : "Import / Production Facility, Corporate Industrial Hub Zone";

                            // Dynamic Flash Offer Strip & Countdown Processing
                            string flashTxt = dr["FlashOfferText"] != DBNull.Value ? dr["FlashOfferText"].ToString() : "";
                            string countdownTxt = dr["OfferCountdown"] != DBNull.Value ? dr["OfferCountdown"].ToString() : "";
                            if (!string.IsNullOrEmpty(flashTxt))
                            {
                                litFlashOfferText.Text = flashTxt.ToUpper();
                                pnlFlashOffer.Visible = true;
                                int totalSeconds = 31500;
                                if (!string.IsNullOrEmpty(countdownTxt) && countdownTxt.Contains(":"))
                                {
                                    try
                                    {
                                        string[] pts = countdownTxt.Split(':');
                                        if (pts.Length == 3)
                                        {
                                            totalSeconds = (Convert.ToInt32(pts[0]) * 3600) + (Convert.ToInt32(pts[1]) * 60) + Convert.ToInt32(pts[2]);
                                        }
                                    }
                                    catch { }
                                }
                                hfOfferSeconds.Value = totalSeconds.ToString();
                            }

                            // Dynamic Bank/Card Offer processing
                            string bankTxt = dr["BankOfferText"] != DBNull.Value ? dr["BankOfferText"].ToString() : "";
                            if (!string.IsNullOrEmpty(bankTxt))
                            {
                                litBankOfferText.Text = bankTxt;
                                pnlBankOffer.Visible = true;
                            }

                            // Seller Offers with fallback
                            string offer1 = dr["FlashOffer"] != DBNull.Value ? dr["FlashOffer"].ToString() : "";
                            litOffer1.Text = !string.IsNullOrEmpty(offer1) ? offer1 : "Get 10% Instant Cash back on using Paytm.";
                            
                            string offer2 = dr["BankOffer"] != DBNull.Value ? dr["BankOffer"].ToString() : "";
                            litOffer2.Text = !string.IsNullOrEmpty(offer2) ? offer2 : "FLAT ₹100 OFF on your first valid digital order.";

                            litFullDesc.Text = dr["Description"].ToString();
                            
                            // ADVANCED BADGE HANDLER
                            string badgeType = dr["Badge"] != DBNull.Value ? dr["Badge"].ToString() : "None";
                            string badgeText = dr["BadgeText"] != DBNull.Value ? dr["BadgeText"].ToString() : "";
                            
                            if (badgeType == "None" || string.IsNullOrEmpty(badgeText))
                            {
                                divBadge.Visible = false;
                            }
                            else
                            {
                                divBadge.Visible = true;
                                litBadge.Text = badgeText;
                                
                                // Premium visual thematic styling for the badge
                                if (badgeType == "Hot") {
                                    divBadge.Attributes["class"] = "pd-tag-sale";
                                    divBadge.Attributes["style"] = "background:#ef4444 !important; color:#fff;";
                                    iconBadge.Attributes["class"] = "fas fa-fire";
                                }
                                else if (badgeType == "New") {
                                    divBadge.Attributes["class"] = "pd-tag-sale";
                                    divBadge.Attributes["style"] = "background:#3b82f6 !important; color:#fff;";
                                    iconBadge.Attributes["class"] = "fas fa-star-of-life";
                                }
                                else if (badgeType == "Best") {
                                    divBadge.Attributes["class"] = "pd-tag-sale";
                                    divBadge.Attributes["style"] = "background:#10b981 !important; color:#fff;";
                                    iconBadge.Attributes["class"] = "fas fa-trophy";
                                }
                                else if (badgeType == "Sale") {
                                    divBadge.Attributes["class"] = "pd-tag-sale";
                                    divBadge.Attributes["style"] = "background:#f97316 !important; color:#fff;";
                                    iconBadge.Attributes["class"] = "fas fa-bolt";
                                }
                                else {
                                    divBadge.Attributes["class"] = "pd-tag-sale";
                                    iconBadge.Attributes["class"] = "fas fa-tags";
                                }
                            }

                            // Main image — normalize path so ~/uploads resolves correctly
                            if (dr["MainImage"] != DBNull.Value && !string.IsNullOrEmpty(dr["MainImage"].ToString()))
                                mainImageUrl = NormalizeImagePath(dr["MainImage"].ToString());

                            // Size dynamic list with Variant Stock support
                            string fallbackSizes = dr["SizeOptions"] != DBNull.Value ? dr["SizeOptions"].ToString() : "";
                            LoadSizes(productId, fallbackSizes, productStock);
                            
                            // COLOR HANDLER: Check if part of a Multi-Product variant group
                            string groupKey = dr["ColorGroupKey"] != DBNull.Value ? dr["ColorGroupKey"].ToString() : "";
                            bool groupLoaded = false;
                            if (!string.IsNullOrEmpty(groupKey))
                            {
                                groupLoaded = LoadGroupColors(groupKey);
                            }

                            if (!groupLoaded)
                            {
                                // Fallback to static text colors
                                BindOptionList(dr["ColorOptions"], rptColors, pnlColors);
                            }

                            // Gallery logic
                            string gStr = dr["GalleryUrls"] != DBNull.Value ? dr["GalleryUrls"].ToString() : "";
                            if (!string.IsNullOrEmpty(gStr))
                            {
                                var images = gStr.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                                                 .Select(s => NormalizeImagePath(s.Trim())).ToList();
                                rptGallery.DataSource = images;
                                rptGallery.DataBind();
                            }

                            dr.Close(); 

                            // Wishlist check — MUST be after dr.Close() to avoid MARS conflict
                            try {
                                using (SqlConnection wCon = new SqlConnection(strcon)) {
                                    wCon.Open();
                                    string wQ = "SELECT COUNT(*) FROM WishlistItems WHERE ProductId=@p AND SessionId=@s";
                                    using (SqlCommand wCmd = new SqlCommand(wQ, wCon)) {
                                        wCmd.Parameters.AddWithValue("@p", productId);
                                        wCmd.Parameters.AddWithValue("@s", Session.SessionID);
                                        isInWishlist = (Convert.ToInt32(wCmd.ExecuteScalar()) > 0);
                                    }
                                }
                            } catch { isInWishlist = false; }

                            LoadReviews(productId);
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

        private void LoadSizes(int pid, string fallbackSizes, int globalStock) 
        {
            List<SizeItem> sizes = new List<SizeItem>();
            try {
                using(SqlConnection con = new SqlConnection(strcon)) {
                    string q = "SELECT VariantValue, Stock FROM ProductVariants WHERE ProductId = @pid AND VariantType='Size'";
                    using(SqlCommand cmd = new SqlCommand(q, con)) {
                        cmd.Parameters.AddWithValue("@pid", pid);
                        con.Open();
                        SqlDataReader dr = cmd.ExecuteReader();
                        while(dr.Read()) {
                            sizes.Add(new SizeItem { 
                                Name = dr["VariantValue"].ToString(), 
                                Stock = Convert.ToInt32(dr["Stock"]) 
                            });
                        }
                        dr.Close();
                    }
                }
            } catch { }

            if(sizes.Count == 0 && !string.IsNullOrEmpty(fallbackSizes)) {
                var items = fallbackSizes.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                                         .Select(s => s.Trim()).ToList();
                foreach(var item in items) {
                    sizes.Add(new SizeItem { Name = item, Stock = globalStock });
                }
            }

            if(sizes.Count > 0) {
                rptSizes.DataSource = sizes;
                rptSizes.DataBind();
                pnlSizes.Visible = true;
            } else {
                pnlSizes.Visible = false;
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

        // Normalize image path: ~/... → /uploads/... | http(s):// stays as-is | /path stays as-is
        private string NormalizeImagePath(string path)
        {
            if (string.IsNullOrEmpty(path)) return "";
            if (path.StartsWith("http://", StringComparison.OrdinalIgnoreCase) ||
                path.StartsWith("https://", StringComparison.OrdinalIgnoreCase) ||
                path.StartsWith("//"))
                return path; // absolute URL, return as-is
            
            if (path.StartsWith("~/"))
                return path.Substring(1); // ~/uploads/... → /uploads/...
            
            if (!path.StartsWith("/"))
                return "/" + path; // ensure leading slash
            
            return path;
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

        private bool LoadGroupColors(string key)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    // Fetch sibling products with same group key, falling back to ColorName if direct Hex swatch is omitted
                    string q = "SELECT Id, Slug, ColorName, ISNULL(NULLIF(ColorCode, ''), ColorName) AS ColorCode FROM SellerProducts WHERE ColorGroupKey = @key AND IsActive = 1 AND ((ColorCode IS NOT NULL AND ColorCode != '') OR (ColorName IS NOT NULL AND ColorName != ''))";
                    using (SqlCommand cmd = new SqlCommand(q, con))
                    {
                        cmd.Parameters.AddWithValue("@key", key);
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        // Only consider loaded if there are multiple product variations to actually link/switch between
                        if (dt.Rows.Count > 1)
                        {
                            rptGroupColors.DataSource = dt;
                            rptGroupColors.DataBind();
                            pnlGroupColors.Visible = true;
                            pnlColors.Visible = false; // Hide legacy text colors
                            return true;
                        }
                    }
                }
            }
            catch { }
            return false;
        }
    }
}
