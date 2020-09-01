public with sharing class GetRoute {

    public static string startpoint{get{
        startpoint = apexpages.currentpage().getparameters().get('startpoint');
        return startpoint;
    } set;}
    public static string endpoint{get{
        endpoint = apexpages.currentpage().getparameters().get('endpoint');
        return endpoint;
    } set;}
    
    public void nothing(){}   
}