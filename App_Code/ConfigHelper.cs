using System;
using System.Data;
using System.Configuration;
using System.Data.SqlClient;

namespace ecommerce_mlm
{
    public static class ConfigHelper
    {
        private static string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;

        public static string GetConfig(string key, string defaultValue = "")
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    // Using standard enterprise stored procedure for performance and security
                    using (SqlCommand cmd = new SqlCommand("sp_GetSystemSetting", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@ConfigKey", key);
                        
                        object result = cmd.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                        {
                            string dbVal = result.ToString();
                            if (!string.IsNullOrEmpty(dbVal)) return dbVal;
                        }
                    }
                }
            }
            catch 
            {
                // Catch case if stored procedure is not created yet, fallback to inline query
                try 
                {
                    using (SqlConnection con = new SqlConnection(strcon))
                    {
                        con.Open();
                        string sqlFallback = "SELECT ConfigValue FROM SystemSettings WHERE ConfigKey = @key";
                        using (SqlCommand cmd = new SqlCommand(sqlFallback, con))
                        {
                            cmd.Parameters.AddWithValue("@key", key);
                            object res = cmd.ExecuteScalar();
                            if (res != null && res != DBNull.Value) return res.ToString();
                        }
                    }
                }
                catch { }
            }

            // Universal cascade back to Web.config appSettings
            string fallback = ConfigurationManager.AppSettings[key];
            return !string.IsNullOrEmpty(fallback) ? fallback : defaultValue;
        }
    }
}
