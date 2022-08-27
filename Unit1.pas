unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo,
  REST.Types, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FMX.Objects, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  REST.Response.Adapter, REST.Client, Data.Bind.Components,
  Data.Bind.ObjectScope;

type
  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    Label1: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Button1: TButton;
    Memo1: TMemo;
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    RESTResponseDataSetAdapter1: TRESTResponseDataSetAdapter;
    FDMemTable1: TFDMemTable;
    Image1: TImage;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses
  System.JSON
, System.Net.HttpClientComponent
, System.Net.URLClient
, System.Net.HttpClient;

procedure TForm1.Button1Click(Sender: TObject);
begin
  RESTClient1.ResetToDefaults;
  RESTClient1.Accept := 'application/json';
  RESTClient1.AcceptCharset := 'UTF-8, *;q=0.8';
  RESTClient1.BaseURL := Format('https://api.apilayer.com/social_asset/facebook/url?apikey=%s&url=%s', [Edit1.Text, Edit2.Text]);
  RESTResponse1.ContentType := 'application/json';

  Memo1.Text := RESTClient1.BaseURL;

  RESTRequest1.Execute;

  var JSONValue := TJSONObject.ParseJSONValue(RESTResponse1.Content);
  try
    if JSONValue is TJSONObject then
    begin
      Memo1.Lines.Clear;
      Memo1.Text := RESTResponse1.Content;
      Memo1.Text := 'Created image URL: ' + JSONValue.GetValue<String>('url');


      // download and show the resized image
      var MemoryStream := TMemoryStream.Create;
      var HTTPClient   := TNetHTTPClient.Create(nil);
      var HTTPRequest  := TNetHTTPRequest.Create(nil);
      HTTPRequest.Client := HTTPClient;

      try
        var ImageURL := JSONValue.GetValue<String>('url');
        HTTPRequest.Get(ImageURL, MemoryStream);
        MemoryStream.Seek(0, soFromBeginning);
        Image1.Bitmap.LoadFromStream(MemoryStream);
      finally
        FreeAndNil(MemoryStream);
        FreeAndNil(HTTPClient);
        FreeAndNil(HTTPRequest);
      end;


    end;
  finally
    JSONValue.Free;
  end;

end;

end.
