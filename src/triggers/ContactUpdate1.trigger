trigger ContactUpdate1 on SocialPost (after insert,after update) {
    list<SocialPost>post=new list<SocialPost>();
    list<socialPost>allPostForPersona=new list<SocialPost>();
    list<SocialPersona>SoPer=new list<SocialPersona>();
    integer positive=0;
    integer negative=0;
    integer totalpostForPersona;
    integer overallSentiment=0;
    list<Product2>product=new list<Product2>();
    map<string,string>productName=new map<string,string>();
   product=[select name from product2];
    for(product2 p:product){
        string name=p.name;
        string UpperCaseName=name.toUpperCase();
        productName.put(UpperCaseName,name);
    }
    for (socialPost sp: trigger.new){
        if(trigger.isupdate && trigger.isafter){
            post=[select whoId,PersonaId,Notes from socialpost where id=:sp.id];
           
        if(string.isNotBlank(post[0].Notes)){
            string s=post[0].Notes;
            list<string>sentencesplit=new list<string>();
            if(s.contains(';')){
                system.debug('contain semicolon');
                List<String> lstAlpha = s.split(';');
                for (string w1 : lstAlpha) {
                    string s2=w1;
                    
                    list<string>words=s2.split(' '); 
                    
                  for (string w : words) {
                        
                       
                            if(w=='Thar'||w=='Mahindra Thar'||w=='thar'||w=='mahindra thar'){
                                
                                ACE_Product_Interest__c PI=new ACE_Product_Interest__c();
                            PI.Name='Mahindra Thar';
                            PI.Product__c='01t5D000002cXzuQAE';
                            PI.Lead__c=post[0].whoId;
                            insert PI;
                            ACE_Source_Tracker__c ST=new ACE_Source_Tracker__c();
                            ST.ACE_Product_Interest__c=PI.Id;
                            ST.Lead__c=post[0].whoId;
                            ST.ACE_Source__c='Social media';
                            ST.ACE_SubSource__c='Facebook.com';
                            insert ST;
                            
                        } 
                    }
                }
                
            }
            else{
                list<string>words=s.split('\\s');            
             for (string w : words) {
                        
                       
                            if(w=='Thar'||w=='Mahindra Thar'||w=='thar'||w=='mahindra thar'){
                                
                                ACE_Product_Interest__c PI=new ACE_Product_Interest__c();
                            PI.Name='Mahindra Thar';
                            PI.Product__c='01t5D000002cXzuQAE';
                            PI.Lead__c=post[0].whoId;
                            insert PI;
                            ACE_Source_Tracker__c ST=new ACE_Source_Tracker__c();
                            ST.ACE_Product_Interest__c=PI.Id;
                            ST.Lead__c=post[0].whoId;
                            ST.ACE_Source__c='Social media';
                            ST.ACE_SubSource__c='Facebook.com';
                            insert ST;
                            
                        } 
                    }
            }   
        } 
            if (post[0].PersonaId!=null){
                allPostForPersona=[select id,Sentiment from socialpost where personaId=:post[0].PersonaId];
            }
            if(!allPostForPersona.isEmpty()){
                totalpostForPersona=allPostForPersona.size();
                if(totalpostForPersona>3){
                    for(socialPost sp3:allPostForPersona){
                        if(sp3.Sentiment=='positive'){
                            positive=positive+1;
                        }
                        else if(sp3.Sentiment=='Negative'){
                            negative=negative+1;
                        }
                    }
                }
            }
            if(post[0].PersonaId!=null){
                SoPer=[select id,total_post__c,Type__c,Overall_Sentiment__c from SocialPersona where id=:post[0].PersonaId];
                if(positive>negative){
                    SoPer[0].Type__c='Promoter';
                    SoPer[0].Overall_Sentiment__c='Positive';
                }
                else if(negative>positive){
                    SoPer[0].Type__c='Detractor';
                    SoPer[0].Overall_Sentiment__c='Negative';
                }
                SoPer[0].Total_Post__c=totalpostForPersona;
                update SoPer[0];
            }
        }
              if(trigger.isInsert && trigger.isafter){
            post=[select whoId,PersonaId,Notes from socialpost where id=:sp.id];
           
        if(string.isNotBlank(post[0].Notes)){
            string s=post[0].Notes;
            list<string>sentencesplit=new list<string>();
            if(s.contains(';')){
                system.debug('contain semicolon');
                List<String> lstAlpha = s.split(';');
                for (string w1 : lstAlpha) {
                    string s2=w1;
                    
                    list<string>words=s2.split(' '); 
                  for (string w : words) {
                        
                       
                            if(w=='Thar'||w=='Mahindra Thar'||w=='thar'||w=='mahindra thar'){
                                
                                ACE_Product_Interest__c PI=new ACE_Product_Interest__c();
                            PI.Name='Mahindra Thar';
                            PI.Product__c='01t5D000002cXzuQAE';
                            PI.Lead__c=post[0].whoId;
                            insert PI;
                            ACE_Source_Tracker__c ST=new ACE_Source_Tracker__c();
                            ST.ACE_Product_Interest__c=PI.Id;
                            ST.Lead__c=post[0].whoId;
                            ST.ACE_Source__c='Social media';
                            ST.ACE_SubSource__c='Facebook.com';
                            insert ST;
                            
                        } 
                    }
                }
                
            }
            else{
                list<string>words=s.split('\\s');            
              for (string w : words) {
                        
                       
                            if(w=='Thar'||w=='Mahindra Thar'||w=='thar'||w=='mahindra thar'){
                                
                                ACE_Product_Interest__c PI=new ACE_Product_Interest__c();
                            PI.Name='Mahindra Thar';
                            PI.Product__c='01t5D000002cXzuQAE';
                            PI.Lead__c=post[0].whoId;
                            insert PI;
                            ACE_Source_Tracker__c ST=new ACE_Source_Tracker__c();
                            ST.ACE_Product_Interest__c=PI.Id;
                            ST.Lead__c=post[0].whoId;
                            ST.ACE_Source__c='Social media';
                            ST.ACE_SubSource__c='Facebook.com';
                            insert ST;
                            
                        } 
                    }
            }   
        } 
            if (post[0].PersonaId!=null){
                allPostForPersona=[select id,Sentiment from socialpost where personaId=:post[0].PersonaId];
            }
            if(!allPostForPersona.isEmpty()){
                totalpostForPersona=allPostForPersona.size();
                if(totalpostForPersona>3){
                    for(socialPost sp3:allPostForPersona){
                        if(sp3.Sentiment=='positive'){
                            positive=positive+1;
                        }
                        else if(sp3.Sentiment=='Negative'){
                            negative=negative+1;
                        }
                    }
                }
            }
            if(post[0].PersonaId!=null){
                SoPer=[select id,total_post__c,Type__c,Overall_Sentiment__c from SocialPersona where id=:post[0].PersonaId];
                if(positive>negative){
                    SoPer[0].Type__c='Promoter';
                    SoPer[0].Overall_Sentiment__c='Positive';
                }
                else if(negative>positive){
                    SoPer[0].Type__c='Detractor';
                    SoPer[0].Overall_Sentiment__c='Negative';
                }
                SoPer[0].Total_Post__c=totalpostForPersona;
                update SoPer[0];
            }
        }
    }
    
    
}