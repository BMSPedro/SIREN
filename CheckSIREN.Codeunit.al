codeunit 50110 CheckSIREN
{
    procedure checkSIREN(sirenno: text; result: Dictionary of [text, text])
    var
        jsonMngt: Codeunit "JSON Management";
        httpClient: HttpClient;
        ContentHttpHeader: HttpHeaders;
        httpReponseMsg: HttpResponseMessage;
        httpContent: HttpContent;
        response: text;
        textValue: text;
    begin
        httpContent.GetHeaders(ContentHttpHeader);
        httpClient.Get('https://recherche-entreprises.api.gouv.fr/search?q=' + sirenno, httpReponseMsg);

        httpContent := httpReponseMsg.Content;
        httpContent.ReadAs(response);

        if not httpReponseMsg.IsSuccessStatusCode() then
            error(response)
        else begin
            jsonMngt.InitializeObject(response);
            jsonMngt.GetArrayPropertyValueAsStringByName('results', response);
            jsonMngt.GetStringPropertyValueByName('total_results', textValue);
            if textValue <> '' then begin
                result.Add('total_results', textValue);

                JsonMngt.InitializeCollection(response);
                JsonMngt.GetObjectFromCollectionByIndex(response, 0);
                jsonMngt.InitializeObject(response);
                jsonMngt.GetstringPropertyValueByName('nom_complet', textValue);
                result.Add('nom_complet', textValue);
                jsonMngt.GetstringPropertyValueByName('nombre_etablissements_ouverts', textValue);
                result.Add('nombre_etablissements_ouverts', textValue);

                jsonMngt.GetArrayPropertyValueAsStringByName('siege', response);
                jsonMngt.InitializeObject(response);
                jsonMngt.GetstringPropertyValueByName('adresse', textValue);
                result.add('adresse', textValue);
                jsonMngt.GetstringPropertyValueByName('code_postal', textValue);
                result.add('code_postal', textValue);
                jsonMngt.GetstringPropertyValueByName('libelle_commune', textValue);
                result.add('libelle_commune', textValue);
            end;
        end;
    end;


}