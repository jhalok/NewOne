trigger Contact_update on SocialPost (after insert,after update) {
    list<SocialPost>post=new list<SocialPost>();
    list<socialPost>allPostForPersona=new list<SocialPost>();
    list<SocialPersona>SoPer=new list<SocialPersona>();
    integer positive=0;
    integer negative=0;
    integer totalpostForPersona;
    integer overallSentiment=0;
    
    for (socialPost sp: trigger.new){
        if(trigger.isupdate && trigger.isafter){
            post=[select whoId,PersonaId from socialpost where id=:sp.id];
            if (post[0].PersonaId!=null){
                allPostForPersona=[select id,Sentiment from socialpost where personaId=:post[0].PersonaId];
            }
        }
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