using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace EcommerceWebsite
{
    public partial class SellerAddEditProduct : System.Web.UI.Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["SellerId"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                lblMsg.Visible = false;
                
                if (Request.QueryString["id"] != null)
                {
                    int productId = Convert.ToInt32(Request.QueryString["id"]);
                    int sellerId = Convert.ToInt32(Session["SellerId"]);
                    
                    litPageTitle.Text = "<i class='fas fa-pen-to-square' style='color:#fbbf24;'></i> Edit Catalog Product";
                    btnSave.Text = "💾 Consolidate & Apply Modifications";
                    btnSave.Style["background"] = "linear-gradient(135deg, #f59e0b, #d97706)";
                    btnSave.Style["box-shadow"] = "0 10px 15px -3px rgba(245, 158, 11, 0.3)";
                    
                    LoadProductForEdit(productId, sellerId);
                }
            }
        }

        private void LoadProductForEdit(int pid, int sid)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string sql = "SELECT * FROM SellerProducts WHERE Id = @pid AND SellerId = @sid";
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@pid", pid);
                        cmd.Parameters.AddWithValue("@sid", sid);
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            DataRow r = dt.Rows[0];

                            // Essential Strings
                            txtName.Text = r["Name"] != DBNull.Value ? r["Name"].ToString() : "";
                            txtBrand.Text = r["Brand"] != DBNull.Value ? r["Brand"].ToString() : "";
                            txtCategory.Text = r["Category"] != DBNull.Value ? r["Category"].ToString() : "";
                            txtSlug.Text = r["Slug"] != DBNull.Value ? r["Slug"].ToString() : "";
                            
                            // Sku Resolution
                            string loadedSku = r["Sku"] != DBNull.Value ? r["Sku"].ToString() : "";
                            txtSku.Text = loadedSku;
                            if (!string.IsNullOrEmpty(loadedSku))
                            {
                                rdoSkuManual.Checked = true;
                                rdoSkuAuto.Checked = false;
                            }
                            else
                            {
                                rdoSkuManual.Checked = false;
                                rdoSkuAuto.Checked = true;
                            }
                            txtStock.Text = r["Stock"] != DBNull.Value ? r["Stock"].ToString() : "0";
                            
                            // Decimals
                            decimal price = r["Price"] != DBNull.Value ? Convert.ToDecimal(r["Price"]) : 0;
                            decimal mrp = r["Mrp"] != DBNull.Value ? Convert.ToDecimal(r["Mrp"]) : 0;
                            txtPrice.Text = price.ToString("F2");
                            txtMrp.Text = mrp.ToString("F2");

                            // Load Offer Strip Data Replica
                            txtFlashOfferText.Text = r["FlashOfferText"] != DBNull.Value ? r["FlashOfferText"].ToString() : "";
                            txtOfferCountdown.Text = r["OfferCountdown"] != DBNull.Value ? r["OfferCountdown"].ToString() : "";
                            txtBankOfferText.Text = r["BankOfferText"] != DBNull.Value ? r["BankOfferText"].ToString() : "";

                            // Dropdowns Selection
                            if (r["ProductType"] != DBNull.Value && ddlProductType.Items.FindByValue(r["ProductType"].ToString()) != null)
                                ddlProductType.SelectedValue = r["ProductType"].ToString();
                            
                            if (r["Gender"] != DBNull.Value && ddlGender.Items.FindByValue(r["Gender"].ToString()) != null)
                                ddlGender.SelectedValue = r["Gender"].ToString();

                            // New Custom Badges & Color Group Load logic
                            if (r["Badge"] != DBNull.Value && ddlBadge.Items.FindByValue(r["Badge"].ToString()) != null)
                                ddlBadge.SelectedValue = r["Badge"].ToString();
                            
                            txtBadgeText.Text = r["BadgeText"] != DBNull.Value ? r["BadgeText"].ToString() : "";
                            txtColorGroupKey.Text = r["ColorGroupKey"] != DBNull.Value ? r["ColorGroupKey"].ToString() : "";
                            txtColorName.Text = r["ColorName"] != DBNull.Value ? r["ColorName"].ToString() : "";
                            txtColorCode.Text = r["ColorCode"] != DBNull.Value ? r["ColorCode"].ToString() : "";

                            // Narrative description
                            txtDesc.Text = r["Description"] != DBNull.Value ? HttpUtility.HtmlDecode(r["Description"].ToString()) : "";

                            // Logistic strings
                            txtWeight.Text = r["Weight"] != DBNull.Value ? r["Weight"].ToString() : "";
                            txtDimensions.Text = r["Dimensions"] != DBNull.Value ? r["Dimensions"].ToString() : "";
                            txtColors.Text = r["ColorOptions"] != DBNull.Value ? r["ColorOptions"].ToString() : "";
                            txtSizes.Text = r["SizeOptions"] != DBNull.Value ? r["SizeOptions"].ToString() : "";
                            txtShipping.Text = r["ShippingClass"] != DBNull.Value ? r["ShippingClass"].ToString() : "";

                            // Manufacturer fields
                            txtMfgName.Text = r["ManufacturerName"] != DBNull.Value ? r["ManufacturerName"].ToString() : "";
                            txtMfgCountry.Text = r["ManufacturerCountry"] != DBNull.Value ? r["ManufacturerCountry"].ToString() : "";
                            txtMfgAddress.Text = r["ManufacturerAddress"] != DBNull.Value ? r["ManufacturerAddress"].ToString() : "";

                            // SEO fields
                            txtMetaTitle.Text = r["MetaTitle"] != DBNull.Value ? r["MetaTitle"].ToString() : "";
                            txtMetaKeywords.Text = r["MetaKeywords"] != DBNull.Value ? r["MetaKeywords"].ToString() : "";
                            txtMetaDesc.Text = r["MetaDescription"] != DBNull.Value ? r["MetaDescription"].ToString() : "";

                            // Visibility Switch override
                            chkActive.Checked = r["IsActive"] != DBNull.Value ? Convert.ToBoolean(r["IsActive"]) : true;

                            // Render Multi-Image Dynamic Gallery exactly as requested in workflow
                            if (r["GalleryUrls"] != DBNull.Value && !string.IsNullOrEmpty(r["GalleryUrls"].ToString()))
                            {
                                string[] rawList = r["GalleryUrls"].ToString().Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                                System.Text.StringBuilder galBuilder = new System.Text.StringBuilder();
                                
                                foreach (string item in rawList)
                                {
                                    string cPath = item.StartsWith("~") ? item.Substring(1) : item;
                                    if (!cPath.StartsWith("/")) cPath = "/" + cPath;
                                    
                                    string fname = Path.GetFileName(cPath);
                                    
                                    // Render precise HTML card component mapping to workflow attachment
                                    galBuilder.AppendFormat(
                                        "<div class='ex-gal-card'>" +
                                        "  <div class='ex-gal-img-wrap'><img src='{0}' alt='Gallery photo' /></div>" +
                                        "  <div class='ex-gal-filename' title='{1}'>{1}</div>" +
                                        "  <label class='ex-gal-remove-lbl'>" +
                                        "    <input type='checkbox' onclick=\"trackRemoval('{2}', this)\" /> Remove image" +
                                        "  </label>" +
                                        "</div>", cPath, fname, item);
                                }
                                
                                if (galBuilder.Length > 0)
                                {
                                    litGalleryExistingThumbs.Text = galBuilder.ToString();
                                    pnlGalleryExisting.Visible = true;
                                }
                            }

                            // =====================================================
                            // LOAD SIZE-WISE VARIANTS DATA FOR DYNAMIC MATRIX
                            // =====================================================
                            string varSql = "SELECT * FROM ProductVariants WHERE ProductId = @Pid";
                            using (SqlCommand varCmd = new SqlCommand(varSql, con))
                            {
                                varCmd.Parameters.AddWithValue("@Pid", pid);
                                SqlDataAdapter vda = new SqlDataAdapter(varCmd);
                                DataTable vdt = new DataTable();
                                vda.Fill(vdt);

                                if (vdt.Rows.Count > 0)
                                {
                                    System.Collections.Generic.List<string> varParts = new System.Collections.Generic.List<string>();
                                    foreach (DataRow vRow in vdt.Rows)
                                    {
                                        string vSize = vRow["VariantValue"].ToString();
                                        string vStock = vRow["Stock"].ToString();
                                        string vSku = vRow["Sku"] != DBNull.Value ? vRow["Sku"].ToString() : "";
                                        string vPrice = vRow["PriceOffset"] != DBNull.Value ? Convert.ToDecimal(vRow["PriceOffset"]).ToString("F2") : "0.00";

                                        // Format: Size:Stock:Sku:Price
                                        varParts.Add(string.Format("{0}:{1}:{2}:{3}", vSize, vStock, vSku, vPrice));
                                    }
                                    // Set Flat String into Hidden Field for Javascript Parsing
                                    hfVariantData.Value = string.Join("|", varParts.ToArray());
                                }
                            }

                        }
                        else
                        {
                            Response.Redirect("Products.aspx");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowStatus("Data Loading Pipeline Interrupted: " + ex.Message, true);
            }
        }

        private void SetupExistingMediaLink(object dbVal, Panel pnl, HyperLink hl)
        {
            if (dbVal != DBNull.Value && !string.IsNullOrEmpty(dbVal.ToString()))
            {
                string path = dbVal.ToString();
                string clean = path.StartsWith("~") ? path.Substring(1) : path;
                if (!clean.StartsWith("/")) clean = "/" + clean;
                
                hl.NavigateUrl = clean;
                pnl.Visible = true;
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;
            
            int sellerId = Convert.ToInt32(Session["SellerId"]);
            int targetId = Request.QueryString["id"] != null ? Convert.ToInt32(Request.QueryString["id"]) : 0;

            try
            {
                // STAGE 1: Media Files Acquisition Engine
                string finalMainImagePath = ProcessMediaUpload(fuMain, "main_p");
                
                // Auto-derive thumbnail pointer from showroom image if uploaded
                string finalThumbPath = finalMainImagePath; 

                // Master list to store the exact, final array of gallery paths to persist
                System.Collections.Generic.List<string> finalGalleryList = new System.Collections.Generic.List<string>();

                // A. HARVEST REMOVAL SYSTEM (FILTER OUT USER-DELETED IMAGES)
                string removedString = hfRemovedGalleryUrls.Value; // Sequence separator: |
                string[] removedArray = !string.IsNullOrEmpty(removedString) 
                    ? removedString.Split(new[] { '|' }, StringSplitOptions.RemoveEmptyEntries) 
                    : new string[0];

                if (targetId > 0)
                {
                    // Sync with existing database records first
                    string rawDbGallery = "";
                    using (SqlConnection conTemp = new SqlConnection(strcon))
                    {
                        conTemp.Open();
                        string q = "SELECT GalleryUrls FROM SellerProducts WHERE Id=@pid AND SellerId=@sid";
                        using (SqlCommand cmdTemp = new SqlCommand(q, conTemp))
                        {
                            cmdTemp.Parameters.AddWithValue("@pid", targetId);
                            cmdTemp.Parameters.AddWithValue("@sid", sellerId);
                            object val = cmdTemp.ExecuteScalar();
                            if (val != null && val != DBNull.Value) rawDbGallery = val.ToString();
                        }
                    }

                    if (!string.IsNullOrEmpty(rawDbGallery))
                    {
                        string[] currentItems = rawDbGallery.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                        foreach (string item in currentItems)
                        {
                            // Filter: keep only if user did NOT check for deletion
                            bool isFlaggedForRemoval = false;
                            foreach (string delPath in removedArray)
                            {
                                if (item.Trim().Equals(delPath.Trim(), StringComparison.OrdinalIgnoreCase))
                                {
                                    isFlaggedForRemoval = true;
                                    break;
                                }
                            }

                            if (!isFlaggedForRemoval)
                            {
                                finalGalleryList.Add(item.Trim());
                            }
                        }
                    }
                }

                // B. APPEND NEWLY SELECT FILES
                if (fuGallery.HasFiles)
                {
                    foreach (HttpPostedFile pFile in fuGallery.PostedFiles)
                    {
                        string savedGal = ProcessPostedFile(pFile, "gal_p");
                        if (!string.IsNullOrEmpty(savedGal))
                        {
                            finalGalleryList.Add(savedGal);
                        }
                    }
                }

                // Build definitive truth string for DB save
                string finalGalleryUrls = finalGalleryList.Count > 0 ? string.Join(",", finalGalleryList) : "";

                // STAGE 2: SQL SP Execution Block
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();

                    // 1. Backend Loop: Validate and Enforce Unique Slug Permutations
                    string baseSlug = "";
                    string rawNameStr = txtName.Text.Trim().ToLower();
                    System.Text.StringBuilder sb = new System.Text.StringBuilder();
                    foreach (char c in rawNameStr)
                    {
                        if ((c >= 'a' && c <= 'z') || (c >= '0' && c <= '9')) sb.Append(c);
                        else if (c == ' ' || c == '-' || c == '_' || c == '/') sb.Append('-');
                    }
                    baseSlug = sb.ToString();
                    while (baseSlug.Contains("--")) { baseSlug = baseSlug.Replace("--", "-"); }
                    baseSlug = baseSlug.Trim('-');
                    if (string.IsNullOrEmpty(baseSlug)) { baseSlug = "product"; }

                    string uniqueSlug = baseSlug;
                    bool isSlugUnique = false;
                    int attempts = 0;
                    Random rand = new Random();

                    while (!isSlugUnique && attempts < 15)
                    {
                        string checkQ = "SELECT COUNT(1) FROM SellerProducts WHERE Slug = @slug AND Id != @pid";
                        using (SqlCommand checkCmd = new SqlCommand(checkQ, con))
                        {
                            checkCmd.Parameters.AddWithValue("@slug", uniqueSlug);
                            checkCmd.Parameters.AddWithValue("@pid", targetId);
                            int count = Convert.ToInt32(checkCmd.ExecuteScalar());
                            if (count == 0)
                            {
                                isSlugUnique = true;
                            }
                            else
                            {
                                // Collision: Append dynamic numeric suffix
                                uniqueSlug = baseSlug + "-" + rand.Next(100, 9999).ToString();
                                attempts++;
                            }
                        }
                    }

                    using (SqlCommand cmd = new SqlCommand("dbo.UpsertSellerProduct", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;

                        // Resolve algorithmic automated SKU vs manual override
                        string resolvedSku = txtSku.Text.Trim();
                        if (rdoSkuAuto.Checked || string.IsNullOrEmpty(resolvedSku))
                        {
                            string rawCat = txtCategory.Text.Trim().Replace(" ", "").ToUpper();
                            string pfxCat = rawCat.Length >= 3 ? rawCat.Substring(0, 3) : (rawCat + "XYZ").Substring(0, 3);
                            
                            string rawName = txtName.Text.Trim().Replace(" ", "").ToUpper();
                            string pfxName = rawName.Length >= 4 ? rawName.Substring(0, 4) : (rawName + "ABCD").Substring(0, 4);
                            
                            resolvedSku = string.Format("{0}-{1}-{2}", pfxCat, pfxName, new Random().Next(1000, 9999));
                        }

                        // Core inputs
                        cmd.Parameters.AddWithValue("@Id", targetId);
                        cmd.Parameters.AddWithValue("@SellerId", sellerId);
                        cmd.Parameters.AddWithValue("@Name", txtName.Text.Trim());
                        cmd.Parameters.AddWithValue("@Slug", uniqueSlug); // Pass our guaranteed unique slug!
                        cmd.Parameters.AddWithValue("@Brand", (object)txtBrand.Text.Trim() ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@Sku", resolvedSku);
                        cmd.Parameters.AddWithValue("@Category", txtCategory.Text.Trim());
                        cmd.Parameters.AddWithValue("@Price", Convert.ToDecimal(txtPrice.Text.Trim()));
                        cmd.Parameters.AddWithValue("@Mrp", Convert.ToDecimal(txtMrp.Text.Trim()));
                        cmd.Parameters.AddWithValue("@Stock", Convert.ToInt32(txtStock.Text.Trim()));
                        cmd.Parameters.AddWithValue("@IsActive", chkActive.Checked);

                        // Imagery (Maintain database constraints - pass definitive gallery truth)
                        cmd.Parameters.AddWithValue("@MainImage", string.IsNullOrEmpty(finalMainImagePath) ? DBNull.Value : (object)finalMainImagePath);
                        cmd.Parameters.AddWithValue("@ThumbnailUrl", string.IsNullOrEmpty(finalThumbPath) ? DBNull.Value : (object)finalThumbPath);
                        cmd.Parameters.AddWithValue("@GalleryUrls", (object)finalGalleryUrls);


                        // Descriptive narrative encoded securely
                        cmd.Parameters.AddWithValue("@Description", HttpUtility.HtmlEncode(txtDesc.Text.Trim()));

                        // Structural extra grids
                        cmd.Parameters.AddWithValue("@ProductType", ddlProductType.SelectedValue);
                        cmd.Parameters.AddWithValue("@Gender", ddlGender.SelectedValue);
                        cmd.Parameters.AddWithValue("@Weight", (object)txtWeight.Text.Trim() ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@Dimensions", (object)txtDimensions.Text.Trim() ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@ColorOptions", (object)txtColors.Text.Trim() ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@SizeOptions", (object)txtSizes.Text.Trim() ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@ShippingClass", (object)txtShipping.Text.Trim() ?? DBNull.Value);

                        // Meta Optimization Stream
                        cmd.Parameters.AddWithValue("@MetaTitle", (object)txtMetaTitle.Text.Trim() ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@MetaKeywords", (object)txtMetaKeywords.Text.Trim() ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@MetaDescription", (object)txtMetaDesc.Text.Trim() ?? DBNull.Value);

                        // Compliance & Manufacturer Parameters
                        cmd.Parameters.AddWithValue("@ManufacturerName", (object)txtMfgName.Text.Trim() ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@ManufacturerCountry", (object)txtMfgCountry.Text.Trim() ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@ManufacturerAddress", (object)txtMfgAddress.Text.Trim() ?? DBNull.Value);

                        // Custom Catalog Upgrades: Badges & Grouping
                        cmd.Parameters.AddWithValue("@Badge", ddlBadge.SelectedValue);
                        cmd.Parameters.AddWithValue("@BadgeText", (object)txtBadgeText.Text.Trim() ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@ColorGroupKey", (object)txtColorGroupKey.Text.Trim() ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@ColorName", (object)txtColorName.Text.Trim() ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@ColorCode", (object)txtColorCode.Text.Trim() ?? DBNull.Value);

                        // Persist New Dynamic Offer Strip
                        cmd.Parameters.AddWithValue("@FlashOfferText", (object)txtFlashOfferText.Text.Trim() ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@OfferCountdown", (object)txtOfferCountdown.Text.Trim() ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@BankOfferText", (object)txtBankOfferText.Text.Trim() ?? DBNull.Value);

                        // Capture output ID
                        SqlParameter outParam = new SqlParameter("@NewId", SqlDbType.Int);
                        outParam.Direction = ParameterDirection.Output;
                        cmd.Parameters.Add(outParam);

                        cmd.ExecuteNonQuery();
                        
                        int newProdId = Convert.ToInt32(outParam.Value);

                        // =====================================================
                        // SAVE SIZE-WISE VARIANTS & INVENTORY RESERVES
                        // =====================================================
                        string variantRaw = hfVariantData.Value;
                        
                        // 1. Run Delete statement to clear previous states safely
                        using (SqlCommand delCmd = new SqlCommand("DELETE FROM ProductVariants WHERE ProductId = @Pid", con))
                        {
                            delCmd.Parameters.AddWithValue("@Pid", newProdId);
                            delCmd.ExecuteNonQuery();
                        }

                        // 2. Loop through raw flat delimiter string and bulk-insert using SaveProductVariants SP!
                        if (!string.IsNullOrEmpty(variantRaw))
                        {
                            string[] records = variantRaw.Split('|');
                            foreach (string rec in records)
                            {
                                if (string.IsNullOrEmpty(rec)) continue;
                                string[] segments = rec.Split(':');
                                if (segments.Length >= 4)
                                {
                                    string sizeVal = segments[0].Trim();
                                    string stockStr = segments[1].Trim();
                                    string skuStr = segments[2].Trim();
                                    string priceStr = segments[3].Trim();

                                    int stockNum = 0;
                                    int.TryParse(stockStr, out stockNum);

                                    decimal extraPrice = 0;
                                    decimal.TryParse(priceStr, out extraPrice);

                                    if (!string.IsNullOrEmpty(sizeVal))
                                    {
                                        using (SqlCommand varCmd = new SqlCommand("SaveProductVariants", con))
                                        {
                                            varCmd.CommandType = CommandType.StoredProcedure;
                                            varCmd.Parameters.AddWithValue("@ProductId", newProdId);
                                            varCmd.Parameters.AddWithValue("@VariantValue", sizeVal);
                                            varCmd.Parameters.AddWithValue("@Sku", string.IsNullOrEmpty(skuStr) ? DBNull.Value : (object)skuStr);
                                            varCmd.Parameters.AddWithValue("@Stock", stockNum);
                                            varCmd.Parameters.AddWithValue("@PriceOffset", extraPrice);
                                            varCmd.ExecuteNonQuery();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Dispatch safely back to inventory overview
                Response.Redirect("Products.aspx");
            }
            catch (Exception ex)
            {
                ShowStatus("Publish Transaction Failure: " + ex.Message, true);
            }
        }

        private string ProcessPostedFile(HttpPostedFile file, string prefix)
        {
            if (file != null && file.ContentLength > 0)
            {
                try
                {
                    string ext = Path.GetExtension(file.FileName).ToLower();
                    if (ext == ".jpg" || ext == ".jpeg" || ext == ".png" || ext == ".webp")
                    {
                        string rootDir = Server.MapPath("~/uploads/products/");
                        if (!Directory.Exists(rootDir))
                        {
                            Directory.CreateDirectory(rootDir);
                        }

                        string filename = prefix + "_" + DateTime.Now.ToString("yyyyMMddHHmmss") + "_" + Guid.NewGuid().ToString().Substring(0, 6) + ext;
                        string physicalPath = Path.Combine(rootDir, filename);
                        
                        file.SaveAs(physicalPath);
                        
                        return "~/uploads/products/" + filename;
                    }
                }
                catch { }
            }
            return "";
        }

        private string ProcessMediaUpload(FileUpload fu, string prefix)
        {
            return fu.HasFile ? ProcessPostedFile(fu.PostedFile, prefix) : "";
        }


        private void ShowStatus(string msg, bool isError)
        {
            lblMsg.Text = msg;
            lblMsg.Visible = true;
            if (isError)
            {
                lblMsg.BackColor = System.Drawing.Color.FromName("#fef2f2");
                lblMsg.ForeColor = System.Drawing.Color.FromName("#dc2626");
                lblMsg.Style["border"] = "1px solid #fecaca";
            }
            else
            {
                lblMsg.BackColor = System.Drawing.Color.FromName("#f0fdf4");
                lblMsg.ForeColor = System.Drawing.Color.FromName("#16a34a");
                lblMsg.Style["border"] = "1px solid #bbf7d0";
            }
        }
    }
}
