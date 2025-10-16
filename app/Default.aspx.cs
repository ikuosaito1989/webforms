using System;
using System.Configuration;
using System.IO;
using System.Text;
using Dapper;
using MySql.Data.MySqlClient;

public partial class _Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e) { }

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (!IsPostBack)
        {
            LoadFile();
        }
    }

    protected void Btn_Click(object sender, EventArgs e)
    {
        try
        {
            var cs = ConfigurationManager.ConnectionStrings["MySql"].ConnectionString;
            using (var conn = new MySqlConnection(cs))
            {
                conn.Open();
                var serverVersion = conn.ExecuteScalar<string>("select version()");
                var now = conn.ExecuteScalar<DateTime>("select now()");
                Label1.Text = $"Connected to MySQL {serverVersion}. Now: {now:u}";
            }
        }
        catch (Exception ex)
        {
            Label1.Text = "DB接続エラー: " + ex.Message;
        }
    }

    protected void BtnWrite_Click(object sender, EventArgs e)
    {
        try
        {
            var path = Server.MapPath("~/App_Data/data.txt");
            var text = (NewLine.Text ?? string.Empty).Replace("\r\n", "\n").Replace("\r", "\n");
            if (!string.IsNullOrWhiteSpace(text))
            {
                File.AppendAllText(path, text + Environment.NewLine, new UTF8Encoding(false));
                StatusLabel.Text = "追記しました";
                NewLine.Text = string.Empty;
            }
            else
            {
                StatusLabel.Text = "追記内容が空です";
            }
        }
        catch (Exception ex)
        {
            StatusLabel.Text = "ファイル書き込みエラー: " + ex.Message;
        }
        finally
        {
            LoadFile();
        }
    }

    private void LoadFile()
    {
        try
        {
            var path = Server.MapPath("~/App_Data/data.txt");
            Directory.CreateDirectory(Path.GetDirectoryName(path));
            if (!File.Exists(path))
            {
                File.WriteAllText(path, "初期コンテンツ\n", new UTF8Encoding(false));
            }
            FileContent.Text = File.ReadAllText(path, Encoding.UTF8);
            StatusLabel.Text = "";
        }
        catch (Exception ex)
        {
            StatusLabel.Text = "ファイル読み込みエラー: " + ex.Message;
        }
    }
}
