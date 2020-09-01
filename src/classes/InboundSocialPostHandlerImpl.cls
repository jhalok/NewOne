global virtual class InboundSocialPostHandlerImpl implements Social.InboundSocialPostHandler {
    
    final static Integer CONTENT_MAX_LENGTH = SocialPost.Content.getDescribe().getLength();
    final static Integer SUBJECT_MAX_LENGTH = Case.Subject.getDescribe().getLength();
    Boolean isNewCaseCreated = false;
    public integer length;
    public string eml='';
    public string ph='';
    public String Phnumber='';
    boolean hasPhone=false;
    boolean hasEml=false;
    boolean ProviderNotMatch=false;
    public list<lead>Leadlist=new list<lead>();
    public list<lead>Leadlist1=new list<lead>();
    public list<Socialpersona>personalist=new list<Socialpersona>(); 
    public list<Socialpersona>personalist1=new list<Socialpersona>(); 
    public list<Socialpersona>personalist2=new list<Socialpersona>();
    public list<Socialpersona>personalist3=new list<Socialpersona>();
    public list<contact> ConList=new list<contact>();
    public list<contact> Conlist2=new list<contact>();
    public  list<contact> Conlist3=new list<contact>();
    Public list<SocialPersona>Personadelete=new list<SocialPersona>();
    Public list<SocialPersona>Personadelete1=new list<SocialPersona>();
    Public list<SocialPersona>PersonaUpd=new list<SocialPersona>();
    public list<SocialPersona>ProviderMatch=new list<SocialPersona>();
    
    public list<Contact>ConTypeUpdate=new list<Contact>();
    public list<Lead>LeadTypeUpdate=new list<Lead>();
    public list<SocialPost>PostSentiment=new list<SocialPost>();
    
    
    
    
    // Reopen case if it has not been closed for more than this number
    global virtual Integer getMaxNumberOfDaysClosedToReopenCase() {
        return 5;
    }
    
    // Create a case if one of these post tags are on the SocialPost, regardless of the skipCreateCase indicator.
    global virtual Set<String> getPostTagsThatCreateCase(){
        set<string> caseString=new set<string>{};
            return caseString;
    }
    
    // If true, use the active case assignment rule if one is found
    global virtual Boolean getUsingCaseAssignmentRule(){
        return false;
    }
    
    global virtual String getDefaultAccountId() {
        return null;
    }
    
    global virtual String getCaseSubject(SocialPost post) {
        String caseSubject = post.Name;
        if (hasReview(post)) {
            String ratingsStr = getRatingString(post);
            caseSubject = ratingsStr + ' • ' + caseSubject;
        }
        
        return caseSubject;
    }
    
    
    global Social.InboundSocialPostResult handleInboundSocialPost(SocialPost post, SocialPersona persona, Map<String, Object> rawData) {
        Social.InboundSocialPostResult result = new Social.InboundSocialPostResult(); 
        system.debug('rawDataValues'+rawData.values());
        system.debug('rawDataKeys'+rawData.keyset());
        /*@@ MatchPhoneOrEmail(post) is used to check if the post's note contain any phone number/ email
@@ Developer: PWC india
*/
        matchPost(post);
        if(post.Classification=='Product Review'){
            post.Headline='Appreciation Post';
        }
        MatchPhoneOrEmail(post);
        //------------------------------Check if contact/Lead exist incase Phone/Email provided [START]------------------------------------------
        if(hasPhone==true && hasEml==false){
            system.debug('Phone'+ph);
            ConList = [SELECT Id,phone,email FROM Contact WHERE phone=:Phnumber or phone=:ph LIMIT 1];
            system.debug('Contact exist');
            if(ConList.isempty()){
                Leadlist=[select id,Email,MobilePhone from lead where MobilePhone=:Phnumber or MobilePhone=:ph limit 1];  
            }
        }
        else if (hasPhone==false && hasEml==true){
            system.debug('email'+eml);
            ConList = [SELECT Id,phone,email FROM Contact WHERE email=:eml LIMIT 1];
            if(ConList.isempty()){
                Leadlist=[select id,Email,MobilePhone from lead where email=:eml limit 1];
            }
        }
        else if(hasPhone==true && hasEml==true){
            system.debug('email_3'+eml);
            ConList = [SELECT Id,phone,email FROM Contact WHERE email=:eml or phone=:ph  LIMIT 1];
            if(!ConList.isEmpty()){
                if(ConList[0].phone==null){
                    ConList[0].phone=ph;
                    update ConList[0];
                }
                else if(ConList[0].email==null){
                    ConList[0].email=eml;
                    update ConList[0];
                }
                
            }
            else{
                
                Leadlist=[select id,Email,MobilePhone from lead where email=:eml or MobilePhone=:ph limit 1];
                if(!leadlist.isEmpty()){
                    if(Leadlist[0].MobilePhone==null){
                        Leadlist[0].MobilePhone=ph;
                        update Leadlist[0];
                    }
                    else if(Leadlist[0].email==null){
                        Leadlist[0].email=eml;
                        update Leadlist[0];
                    }
                }
                
            }
        }
        
        //------------------------------Check if contact/Lead exist incase Phone/Email provided [END]---------------------------------------------- 
        
        //------------------------------if contact/Lead not exist, check if Persona exist [START]----------------------------------------------------
        
        if(ConList.isempty() && leadlist.isempty()){
            matchPersona(persona,post);
            if(persona.id!=null){
                if(hasPhone==true && persona.Phone__c==null ){
                    
                    persona.Phone__c=ph;
                    upsert persona;
                }
                if(hasEml==true && persona.Email__c==null){
                    persona.Email__c=eml;
                    upsert persona;
                }
                
            }
            if(persona.parentId!=null){
                if(persona.ParentId.getSobjectType()==Contact.sObjectType){
                    conlist2=[select id,email,phone from contact where id=:persona.ParentId];
                    System.debug('Persona parent exist');
                    if(hasPhone==true && conlist2[0].Phone==null ){
                        conlist2[0].Phone=ph;
                    }
                    if(hasEml==true && conlist2[0].email==null){
                        conlist2[0].email=eml;
                    }
                    update conlist2;
                }
                if(persona.ParentId.getSobjectType()==lead.sObjectType){
                    leadlist1=[select id,email,MobilePhone from lead where id=:persona.ParentId];
                    if(hasPhone==true && leadlist1[0].MobilePhone==null ){
                        leadlist1[0].MobilePhone=ph;
                    }
                    if(hasEml==true && leadlist1[0].email==null){
                        leadlist1[0].email=eml;
                    }
                    update leadlist1;
                }
            }
        }
        
        //------------------------------if contact/Lead not exist, check if Persona exist [END]----------------------------------------------------
        if ((post.Content != null) && (post.Content.length() > CONTENT_MAX_LENGTH)) {
            post.Content = post.Content.abbreviate(CONTENT_MAX_LENGTH);
        }
        /*if(post.Classification=='Product Review'){
post.Headline='Appreciation Post';
insert post;
system.debug('appreciation post');
buildPersona(persona,post); 
}*/
        
        if (post.Id != null) {
            handleExistingPost(post, persona);
            return result;
        }
        
        setReplyTo(post, persona);
        //------------------------------------Logic if Contact/Lead/Persona exist/not exist [START]---------------------------------------------------- 
        if(ConList.isempty()){
            if(leadlist.isempty()){
                system.debug('call buildpersona');
                if(post.Classification=='Product Review'){
                    post.Headline='Appreciation Post';
                    insert post;
                    system.debug('appreciation post');
                    
                }
                buildPersona(persona,post);
                
                
            }
            else{
                
                post.WhoId=leadlist[0].id;  
                system.debug('leadlist not empty');
            }
            
        }
        else{
            system.debug('ConList has value');
            
            post.WhoId=ConList[0].id;          
        }
        //------------------------------------Logic if Contact/Lead/Persona exist/not exist [END]----------------------------------------------------------
        //-------------------------------- If contact/lead exist,check if any persona exist with same provider[START]-------------------------------
        if(!ConList.isempty()){
            if(!string.isBlank(ph) && string.isBlank(eml)){
                personalist=[select id,provider,parentId from socialpersona where Phone__c=:ph AND parentId=:ConList[0].id ];
                if(personalist.isempty()){
                    ProviderNotMatch=true;  
                }
                Personadelete=[select id,provider,parentId from socialpersona where Phone__c=:ph AND parentId !=:ConList[0].id];
                if(!Personadelete.isEmpty()){
                    delete Personadelete;
                }
            }
            else if(!string.isBlank(eml) && string.isBlank(ph)){
                personalist=[select id,provider,parentId from socialpersona where email__c=:eml AND parentId=:ConList[0].id]; 
                if(personalist.isempty()){
                    ProviderNotMatch=true;  
                }
                Personadelete=[select id,provider,parentId from socialpersona where email__c=:eml AND parentId !=:ConList[0].id]; 
                if(!Personadelete.isEmpty()){
                    delete Personadelete;
                }
            }
            else if(!string.isBlank(eml) && !string.isBlank(ph) ){
                personalist=[select id,provider,parentId,phone__c,email__c from socialpersona where  parentId=:ConList[0].id AND (email__c=:eml or Phone__c=:ph) ];
                //personalist1=[select id,provider,parentId,phone__c,email__c from socialpersona where Phone__c=:ph AND parentId=:ConList[0].id ];
                
                Personadelete=[select id,provider,parentId from socialpersona where (email__c=:eml or Phone__c=:ph) AND parentId !=:ConList[0].id];
                //Personadelete1=[select id,provider,parentId from socialpersona where email__c=:eml AND Phone__c=:ph AND parentId !=:ConList[0].id];
                if(!Personadelete.isEmpty()){
                    delete Personadelete;
                }
                if(personalist.isempty()){
                    ProviderNotMatch=true;  
                }
                
                else{
                    for(socialpersona per:personalist){
                        if(per.phone__c==null){
                            per.phone__c=ph;
                        }
                        if(per.email__c==null){
                            per.email__c=eml; 
                        }
                        personalist3.add(per);
                    }
                    if(!personalist3.isEmpty()){
                        update personalist3;
                    }
                }
                
            }
            
        }
        else if(!leadlist.isEmpty()){
            system.debug('leadlist not empty_1');
            if(!string.isBlank(ph) && string.isBlank(eml)){
                personalist=[select id,provider,parentId from socialpersona where Phone__c=:ph AND parentId=:leadlist[0].id ];
                if(personalist.isempty()){
                    ProviderNotMatch=true;  
                }
                
            }
            else if(!string.isBlank(eml) && string.isBlank(ph)){
                personalist=[select id,provider,parentId from socialpersona where email__c=:eml AND parentId=:leadlist[0].id];
                if(personalist.isempty()){
                    ProviderNotMatch=true;  
                }
                system.debug('lead with email exists');
                
            }
            else if(!string.isBlank(eml) && !string.isBlank(ph) ){
                system.debug('leadlist not empty_2');
                personalist=[select id,provider,parentId,phone__c,email__c from socialpersona where parentId=:leadlist[0].id AND (email__c=:eml or Phone__c=:ph ) ];
                //personalist1=[select id,provider,parentId,phone__c,email__c from socialpersona where Phone__c=:ph AND parentId=:leadlist[0].id ];
                if(personalist.isempty()){
                    ProviderNotMatch=true;  
                }
                else{
                    for(socialpersona per:personalist){
                        if(per.phone__c==null){
                            per.phone__c=ph;
                        }
                        if(per.email__c==null){
                            per.email__c=eml; 
                        }
                        personalist3.add(per);
                    }
                    if(!personalist3.isEmpty()){
                        update personalist3;
                    }
                    
                }
            }
        }
        if(!personalist.isempty()){
            for(SocialPersona sp :personalist){
                if(persona.Provider==sp.Provider){
                    ProviderMatch.add(sp);
                    system.debug('persona match');
                }
            }
            if(!ProviderMatch.isEmpty()){
                post.PersonaId=ProviderMatch[0].Id;
                persona.id=ProviderMatch[0].Id;
                persona.ParentId=ProviderMatch[0].parentId;
            }
            else{
                system.debug('create persona provider not match');
                ProviderNotMatch=true;
                buildPersona(persona,post);
            }
            
        }
        //exist in lead or contact but no persona
        else{
            if(ProviderNotMatch==true){
                buildPersona(persona,post);
            }
            
        }
        //-------------------------------- If contact/lead exist,check if any persona exist with same provider[END]-------------------------------
        
        Case parentCase = buildParentCase(post, persona, rawData);
        if((string.isNotBlank(ph))||string.isNotBlank(eml) || (persona.id!=null) || post.Classification=='Product Review'){
            setRelationshipsOnPost(post, persona, parentCase); 
        }
        
        setModeration(post, rawData);
        if((string.isNotBlank(ph))||string.isNotBlank(eml) || (persona.id!=null && (persona.ParentId.getSobjectType()!=SocialPost.SobjectType)) || post.Classification=='Product Review'){
            system.debug('upsert post');
            upsert post;
            system.debug('After upsert post'+post.id);
        }
        if(isNewCaseCreated){
            System.debug('entry5'); 
            updateCaseSource(post, parentCase);
        }
        if(post.id!=null){
            handlePostAttachments(post, rawData);
        }
        
        return result;
        
    }
Public void MatchPhoneOrEmail(socialPost post){
        if(string.isNotBlank(post.Notes)){
            System.debug('entry4'); 
            string s=post.Notes;
            System.debug('Notes'+s);
            list<string>words=new list<string>();
            
            if(s.contains(';')){
                system.debug('contain semicolon');
                string SpaceString=s.replaceAll(';', ' ');
                system.debug('SpaceString >>'+SpaceString);
                words=SpaceString.split(' ');  
                system.debug('words >>'+words[0]);
           
            }
            else{
                words=s.split('\\s');
             
                }
        for (string w : words) {
                    if(w.isNumeric()){
                        if(w.length()==10){
                            ph=w;
                            Phnumber = w.replaceFirst('(\\d{3})(\\d{3})(\\d+)', '($1) $2-$3');
                            system.debug('Phnumber>>>'+Phnumber);
                            hasPhone=true;
                        }
                    }
                    
                    String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
                    Pattern MyPattern2 = Pattern.compile(emailRegex);
                    Matcher MyMatcher2 = MyPattern2.matcher(w);
                    system.debug('MyMatcher2'+MyMatcher2.matches());
                    if(MyMatcher2.matches()){
                        eml=w; 
                        system.debug('email_2'+w);
                        hasEml=true;
                        
                    }
                }            
             
            }
            
        }
    
    
    private void setModeration(SocialPost post, Map<String, Object> rawData){
        System.debug('entry6'); 
        //if we don't automatically create a case, we should flag the post as requiring moderator review.
        if(post.parentId == null && !isUnsentParent(rawData))
            post.reviewedStatus = 'Needed';
    }
    
    private void updateCaseSource(SocialPost post, Case parentCase){
        System.debug('entry7'); 
        if(parentCase != null) {
            parentCase.SourceId = post.Id;
            //update as a new sobject to prevent undoing any changes done by insert triggers
            update new Case(Id = parentCase.Id, SourceId = parentCase.SourceId);
        }
        
    }
    
    private void handleExistingPost(SocialPost post, SocialPersona persona) {
        System.debug('entry8'); 
        List<SocialPost> existingPosts = [Select Recipient, IsOutbound from SocialPost where id = :post.Id limit 1];
        
        // for any existing outbound post, we don't overwrite its recipient field
        if (!existingPosts.isEmpty() && existingPosts[0].IsOutBound == true && String.isNotBlank(existingPosts[0].Recipient)) {
            post.Recipient = existingPosts[0].Recipient;
            System.debug('entry9'); 
        }
        
        update post;
        if (persona.id != null)
            updatePersona(persona);
    }
    
    private void setReplyTo(SocialPost post, SocialPersona persona) {
        System.debug('entry10'); 
        SocialPost replyTo = findReplyTo(post, persona);
        if(replyTo.id != null) {
            System.debug('entry11'); 
            post.replyToId = replyTo.id;
            post.replyTo = replyTo;
        }
    }
    
    private SocialPersona buildPersona(SocialPersona persona, SocialPost post) {
        //if there is no data match from matchpersona()
        System.debug('entry12'); 
        if (persona.Id == null){
            System.debug('entry13'); 
            createPersona(persona, post);
        }
        //if there is  data match from matchpersona() 
        else
            updatePersona(persona);
        
        return persona;
    }
    
    private void updatePersona(SocialPersona persona) {
        try{   
            update persona;
        }catch(Exception e) {
            System.debug('Error updating social persona: ' + e.getMessage());
        }
    }
    
    private Case buildParentCase(SocialPost post, SocialPersona persona, Map<String, Object> rawData){
        System.debug('entry13'); 
        if(!isUnsentParent(rawData)) {
            System.debug('entry14'); 
            Case parentCase = findParentCase(post, persona);
            if (parentCase != null) {
                System.debug('entry15'); 
                if (!parentCase.IsClosed) {
                    System.debug('entry16'); 
                    return parentCase;
                }
                else if (caseShouldBeReopened(parentCase)) {
                    System.debug('entry17'); 
                    reopenCase(parentCase);
                    return parentCase;
                }
            }
            if(shouldCreateCase(post, rawData)){
                isNewCaseCreated = true;
                System.debug('entry18'); 
                return createCase(post, persona);
                
            }
        }
        
        return null;
    }
    
    private boolean caseShouldBeReopened(Case c){
        System.debug('entry19'); 
        return c.id != null && c.isClosed && System.now() < c.closedDate.addDays(getMaxNumberOfDaysClosedToReopenCase());
    }
    
    private void setRelationshipsOnPost(SocialPost postToUpdate, SocialPersona persona, Case parentCase) {
        System.debug('entry20'); 
        if (persona.Id != null) {
            System.debug('entry21');
            postToUpdate.PersonaId = persona.Id;
            
            if(persona.parentId !=null){
                if(persona.ParentId.getSObjectType() != SocialPost.sObjectType) {
                    System.debug('entry22');
                    postToUpdate.WhoId = persona.ParentId;
                }
            }
        }
        if(parentCase != null) {
            System.debug('entry23');
            postToUpdate.ParentId = parentCase.Id;
        }
    }
    
    private Boolean hasReview(SocialPost post) {
        System.debug('entry24');
        return post.ReviewScore != null;
    }
    
    private String getRatingString(SocialPost post) {
        System.debug('entry25');
        Integer maxNumberOfStars = 5;
        Double reviewScore = post.ReviewScore;
        Double reviewScale = post.ReviewScale;
        if (reviewScore == null) {
            System.debug('entry26');
            reviewScore = 0;
        }
        if (reviewScale == null) {
            System.debug('entry27');
            reviewScale = maxNumberOfStars;
        }
        Integer numberOfStars = Math.floor((reviewScore / reviewScale) * maxNumberOfStars).intValue();
        return numberOfStars.format() + '-Star';
    }
    
    private Case createCase(SocialPost post, SocialPersona persona) {
        System.debug('entry28');
        
        String caseSubject = getCaseSubject(post).abbreviate(SUBJECT_MAX_LENGTH);
        Case newCase = new Case(subject = caseSubject);

        if (persona != null && persona.ParentId != null) {
            System.debug('entry30');
            if (persona.ParentId.getSObjectType() == Contact.sObjectType) {
                System.debug('entry31');
                newCase.ContactId = persona.ParentId;
                //newCase.Persona_Information__c=post.Notes;
            } else if (persona.ParentId.getSObjectType() == Account.sObjectType) {
                System.debug('entry32');
                newCase.AccountId = persona.ParentId;
            }
            else if(persona.ParentId.getSobjectType()==Lead.sobjectType){
                newCase.Lead__c=persona.ParentId;
            }
        }
        if (post != null && post.Provider != null) {
            System.debug('entry33');
            newCase.Origin = post.Provider;
        }
        
        if (getUsingCaseAssignmentRule()){
            //Find the active assignment rules on case
            System.debug('entry34');
            AssignmentRule[] rules = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
            
            if (rules.size() > 0){
                System.debug('entry35');
                //Creating the DMLOptions for "Assign using active assignment rules" checkbox
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.assignmentRuleId= rules[0].id;
                
                //Setting the DMLOption on Case instance
                newCase.setOptions(dmlOpts);
            }
        }
        
        insert newCase;
        return newCase;
    }
    
    private Case findParentCase(SocialPost post, SocialPersona persona) {
        System.debug('entry35');
        Case parentCase = null;
        if (!isChat(post) && (isReplyingToOutboundPost(post) && isSocialPostRecipientSameAsPersona(post.ReplyTo, persona)) || (!isReplyingToOutboundPost(post) && isReplyingToSelf(post,persona))) {
            System.debug('entry36');
            parentCase = findParentCaseFromPostReply(post);
            if (isParentCaseValid(parentCase)) { 
                System.debug('entry37');
                return parentCase;
            }
        }
        
        parentCase = findParentCaseFromPersonaAndRecipient(post, persona);
        if (parentCase == null && isChat(post)) {
            System.debug('entry38');
            parentCase = findParentCaseOfChatFromPersonaAndRecipient(post, persona);	
        }
        return parentCase;
    }
    
    private boolean isChat(SocialPost post) {
        System.debug('entry39');
        return post.messageType == 'Private' || post.messageType == 'Direct';
    }
    
    private boolean isParentCaseValid(Case parentCase) {
        System.debug('entry40');
        return parentCase != null && (!parentCase.IsClosed || caseShouldBeReopened(parentCase));
    }
    
    private Case findParentCaseFromPostReply(SocialPost post) {
        System.debug('entry41');
        if (post.ReplyTo != null && String.isNotBlank(post.ReplyTo.ParentId)) {
            System.debug('entry42');
            List<Case> cases = [SELECT Id, IsClosed, Status, ClosedDate FROM Case WHERE Id = :post.ReplyTo.ParentId LIMIT 1];
            if(!cases.isEmpty()) {
                System.debug('entry43');
                return cases[0];
            }
        }
        return null;
    }
    
    // reply to outbound post
    private boolean isReplyingToOutboundPost(SocialPost post) {
        System.debug('entry44');
        return (post != null && post.ReplyTo != null && post.ReplyTo.IsOutbound);
    }
    
    // replyTo.recipient == inboundSocialPost.persona.externalId
    private boolean isSocialPostRecipientSameAsPersona(SocialPost postWithRecipient, SocialPersona persona) {
        System.debug('entry45');
        return (postWithRecipient != null && postWithRecipient.Recipient == persona.ExternalId);
    }
    
    // is replying to self
    private boolean isReplyingToSelf(SocialPost post, SocialPersona persona) {
        System.debug('entry46');
        return (post != null && 
                persona != null && 
                String.isNotBlank(persona.Id) && 
                post.ReplyTo != null &&
                String.isNotBlank(post.ReplyTo.PersonaId) &&
                post.ReplyTo.PersonaId == persona.id);
    }
    private SocialPost findLatestInboundPostBasedOnPersonaAndRecipient(SocialPost post, SocialPersona persona) {
        System.debug('entry47');
        if (persona != null && String.isNotBlank(persona.Id) && post != null && String.isNotBlank(post.Recipient)) {
            System.debug('entry48');
            List<SocialPost> posts = [SELECT Id, ParentId FROM SocialPost WHERE Provider = :post.provider AND Recipient = :post.Recipient AND PersonaId = :persona.id AND IsOutbound = false ORDER BY CreatedDate DESC LIMIT 1];
            if (!posts.isEmpty()) {
                System.debug('entry49');
                return posts[0];
            }
        }
        return null;
    }
    private SocialPost findLatestInboundPostBasedOnPersona(SocialPost post, SocialPersona persona) {
        System.debug('entry50');
        if (persona != null && String.isNotBlank(persona.Id) && post != null) {
            System.debug('entry51');
            List<SocialPost> posts = [SELECT Id, ParentId FROM SocialPost WHERE Provider = :post.provider AND PersonaId = :persona.id AND IsOutbound = false ORDER BY CreatedDate DESC LIMIT 1];
            if (!posts.isEmpty()) {
                System.debug('entry52');
                /*
string s=post.Content;
list<string>words=s.split('');            
for (string w : words) {
if(w.contains('@')){
persona.Email__c=w;
update persona;
}
}*/ 
                return posts[0];
            }
        }
        return null;
    }
    
    private Case findParentCaseFromPersonaAndRecipient(SocialPost post, SocialPersona persona) {
        System.debug('entry53');
        SocialPost lastestInboundPostWithSamePersonaAndRecipient = findLatestInboundPostBasedOnPersonaAndRecipient(post, persona);
        if (lastestInboundPostWithSamePersonaAndRecipient != null) {
            System.debug('entry54');
            List<Case> cases = [SELECT Id, IsClosed, Status, ClosedDate FROM Case WHERE id = :lastestInboundPostWithSamePersonaAndRecipient.parentId LIMIT 1];
            if(!cases.isEmpty()) {
                System.debug('entry55');
                return cases[0];
            }
        }
        return null;
    }
    
    private Case findParentCaseOfChatFromPersonaAndRecipient(SocialPost post, SocialPersona persona) {
        System.debug('entry56');
        SocialPost lastestReplyToPost = findLatestOutboundReplyToPostBasedOnPersonaAndRecipient(post, persona);
        if (lastestReplyToPost != null) {
            System.debug('entry57');
            List<Case> cases = [SELECT Id, IsClosed, Status, ClosedDate FROM Case WHERE id = :lastestReplyToPost.parentId LIMIT 1];
            if(!cases.isEmpty()) {
                System.debug('entry58');
                return cases[0];
            }
        }
        return null;
    }
    
    private void reopenCase(Case parentCase) {
        System.debug('entry59');
        SObject[] status = [SELECT MasterLabel FROM CaseStatus WHERE IsClosed = false AND IsDefault = true];
        parentCase.Status = ((CaseStatus)status[0]).MasterLabel;
        update parentCase;
    }
    
    private void matchPost(SocialPost post) {
        System.debug('entry60');
        if (post.Id != null) return;
        
        performR6PostIdCheck(post);
        
        if (post.Id == null){
            System.debug('entry61');
            performExternalPostIdCheck(post);
        }
    }
    
    
    private void performR6PostIdCheck(SocialPost post){
        System.debug('entry62');
        if(post.R6PostId == null) return;
        List<SocialPost> postList = [SELECT Id FROM SocialPost WHERE R6PostId = :post.R6PostId LIMIT 1];
        if (!postList.isEmpty()) {
            System.debug('entry63');
            post.Id = postList[0].Id;
            
        }
    }
    
    
    private void performExternalPostIdCheck(SocialPost post) {
        System.debug('entry64');
        if (post.provider == 'Facebook' && post.messageType == 'Private') return;
        if (post.provider == null || post.externalPostId == null) return;
        List<SocialPost> postList = [SELECT Id FROM SocialPost WHERE ExternalPostId = :post.ExternalPostId AND Provider = :post.provider LIMIT 1];
        if (!postList.isEmpty()) {
            System.debug('entry65');
            post.Id = postList[0].Id;
        }
    }
    
    
    private SocialPost findReplyTo(SocialPost post, SocialPersona persona) {
        System.debug('entry66');
        if(post.replyToId != null && post.replyTo == null)
            return findReplyToBasedOnReplyToId(post);
        if(post.responseContextExternalId != null){
            System.debug('entry67');
            if((post.provider == 'Facebook' && post.messageType == 'Private') || (post.provider == 'Twitter' && post.messageType == 'Direct')) {
                SocialPost replyTo = findReplyToBasedOnResponseContextExternalPostIdAndProvider(post);
                if(replyTo.id != null) 
                    return replyTo;
            }
            return findReplyToBasedOnExternalPostIdAndProvider(post);
        }
        return new SocialPost();
    }
    
    private SocialPost findReplyToBasedOnReplyToId(SocialPost post){
        System.debug('entry68');
        List<SocialPost> posts = [SELECT Id, ParentId, IsOutbound, PersonaId, Recipient FROM SocialPost WHERE id = :post.replyToId LIMIT 1];
        if(posts.isEmpty())
            return new SocialPost();
        return posts[0];
    }
    
    private SocialPost findReplyToBasedOnExternalPostIdAndProvider(SocialPost post){
        System.debug('entry69');
        List<SocialPost> posts = [SELECT Id, ParentId, IsOutbound, PersonaId, Recipient FROM SocialPost WHERE Provider = :post.provider AND ExternalPostId = :post.responseContextExternalId LIMIT 1];
        if(posts.isEmpty())
            return new SocialPost();
        return posts[0];
    }
    
    private SocialPost findReplyToBasedOnResponseContextExternalPostIdAndProvider(SocialPost post){
        System.debug('entry70');
        List<SocialPost> posts = [SELECT Id, ParentId, IsOutbound, PersonaId FROM SocialPost WHERE Provider = :post.provider AND Recipient = :post.Recipient AND responseContextExternalId = :post.responseContextExternalId ORDER BY posted DESC NULLS LAST LIMIT 1];
        if(posts.isEmpty())
            return new SocialPost();
        return posts[0];
    }
    
    
    private SocialPost findLatestOutboundReplyToPostBasedOnPersonaAndRecipient(SocialPost post, SocialPersona persona) {
        System.debug('entry71');
        if (persona != null && String.isNotBlank(persona.Id) && post != null) {
            System.debug('entry72');
            List<ExternalSocialAccount> accounts = [SELECT Id FROM ExternalSocialAccount WHERE ExternalAccountId = :post.Recipient];
            if (!accounts.isEmpty()) {
                System.debug('entry73');
                ExternalSocialAccount account = accounts[0];
                List<SocialPost> posts = [SELECT Id, ParentId FROM SocialPost WHERE Provider = :post.provider AND Recipient = :persona.ExternalId AND OutboundSocialAccountId = :account.Id AND IsOutbound = true ORDER BY CreatedDate DESC LIMIT 1];
                if (!posts.isEmpty()) {
                    System.debug('entry74');
                    return posts[0];
                }
            }
        }
        return null;
    }
    
    private void matchPersona(SocialPersona persona,SocialPost post) {
        System.debug('entry75');
        if (persona != null) {
            System.debug('entry76');
            List<SocialPersona> personaList = new List<SocialPersona>();
            if (persona.Provider != 'Other') {
                System.debug('entry77');
                if (String.isNotBlank(persona.ExternalId)) {
                    System.debug('entry78');
                    personaList = [SELECT Id, ParentId FROM SocialPersona WHERE
                                   Provider = :persona.Provider AND
                                   ExternalId = :persona.ExternalId ];
                }
                
            }
            else if(persona.Provider == 'Other' && String.isNotBlank(persona.ExternalId) && String.isNotBlank(persona.MediaProvider)) {
                System.debug('entry80');
                personaList = [SELECT Id, ParentId FROM SocialPersona WHERE
                               MediaProvider = :persona.MediaProvider AND
                               ExternalId = :persona.ExternalId];
            }
            
            if (!personaList.isEmpty()) {
                System.debug('entry82');
                if(personaList.size()>1){
                    for (SocialPersona per:personaList ){
                        if(per.ParentId.getSobjectType()==contact.SobjectType){
                            persona.Id = per.id;
                            persona.ParentId=per.ParentId;
                        }
                        else{
                            personadelete.add(per);
                        }
                    }
                    if(!personadelete.isEmpty()){
                        delete personadelete;
                    }
                }
                else{
                    persona.Id = personaList[0].Id;
                    if(personaList[0].ParentId!=null){
                        persona.ParentId = personaList[0].ParentId;
                    } 
                }
                
            }
        }
    }
    
    private void createPersona(SocialPersona persona, SocialPost post) {
        System.debug('entry83');
        if (persona == null || String.isNotBlank(persona.Id) || !isThereEnoughInformationToCreatePersona(persona)) 
            return;
        //MatchPhoneOrEmail(post);
        
        if((string.isNotBlank(ph) || string.isNotBlank(eml))){
            
            system.debug('inside classification');
            if(ProviderNotMatch==true){
                if(!ConList.isEmpty()){
                    persona.ParentId = ConList[0].Id; 
                }
                else if(!leadlist.isEmpty()){
                    persona.ParentId = leadlist[0].Id; 
                }
                
            }
            else{
                if(post.classification!='Product Review'){
                    SObject parent = createPersonaParent(persona,post);
                    persona.ParentId = parent.Id; 	
                    
                }
                
            }
            
            
            
            
            if(string.isNotBlank(eml)){
                persona.Email__c=eml;
            }
            if(string.isNotBlank(ph)){
                persona.Phone__c=ph;
            }
            persona.Notes__c=post.Notes; 
            if(persona.ParentId ==null && post.classification=='Product Review'){
                persona.ParentId=post.id;
            }
            insert persona;
            
        }
        
        //cannot create persona without parentId
        else if(!string.isNotBlank(ph) && !string.isNotBlank(eml) && post.classification=='Product Review' && persona.ParentId ==null ){
            persona.ParentId=post.id;
            system.debug('Persona for appreciation post'+persona.id);
            insert persona ; 
        }
        if(post.classification=='Product Review'){
            post.personaId=persona.id;
            upsert post;
        }
        
    }
    
    private boolean isThereEnoughInformationToCreatePersona(SocialPersona persona ) {
        System.debug('entry88');
        return String.isNotBlank(persona.Name) && 
            String.isNotBlank(persona.Provider) && 
            String.isNotBlank(persona.MediaProvider);
    }
    
    private boolean shouldCreateCase(SocialPost post, Map<String, Object> rawData) {
        System.debug('entry89');
        return !isUnsentParent(rawData) && (!hasSkipCreateCaseIndicator(rawData) || hasPostTagsThatCreateCase(post));
    }
    
    private boolean isUnsentParent(Map<String, Object> rawData) {
        System.debug('entry90');
        Object unsentParent = rawData.get('unsentParent');
        return unsentParent != null && 'true'.equalsIgnoreCase(String.valueOf(unsentParent));
    }
    
    private boolean hasSkipCreateCaseIndicator(Map<String, Object> rawData) {
        System.debug('entry91');
        Object skipCreateCase = rawData.get('skipCreateCase');
        return skipCreateCase != null && 'true'.equalsIgnoreCase(String.valueOf(skipCreateCase));
    }
    
    private boolean hasPostTagsThatCreateCase(SocialPost post){
        System.debug('entry92');
        Set<String> postTags = getPostTags(post);
        postTags.retainAll(getPostTagsThatCreateCase());
        return !postTags.isEmpty();
    }
    
    private Set<String> getPostTags(SocialPost post){
        System.debug('entry93');
        Set<String> postTags = new Set<String>();
        if(post.postTags != null)
            postTags.addAll(post.postTags.split(',', 0));
        return postTags;
    }
    
    global String getPersonaFirstName(SocialPersona persona) {
        String name = getPersonaName(persona);      
        String firstName = '';
        if (name.contains(' ')) {
            firstName = name.substringBeforeLast(' ');
        }
        firstName = firstName.abbreviate(40);
        return firstName;
    }
    
    global String getPersonaLastName(SocialPersona persona) {   
        String name = getPersonaName(persona);   
        String lastName = name;
        if (name.contains(' ')) {
            lastName = name.substringAfterLast(' ');
        }
        lastName = lastName.abbreviate(80);
        return lastName;
    }
    
    private String getPersonaName(SocialPersona persona) {
        String name = persona.Name.trim();
        if (String.isNotBlank(persona.RealName)) {
            name = persona.RealName.trim();
        }
        return name;
    }
    
    global virtual SObject createPersonaParent(SocialPersona persona,SocialPost post) {
        System.debug('entry94');
        String firstName = getPersonaFirstName(persona);
        String lastName = getPersonaLastName(persona);
        
        Lead lead = new Lead();
        lead.FirstName=firstName;
        lead.LastName=lastName;
       // MatchPhoneOrEmail(post);
        if(string.isNotBlank(ph)){
            lead.MobilePhone=ph; 
        }
        if(string.isNotBlank(eml)){
            lead.Email=eml; 
        }
        String defaultAccountId = getDefaultAccountId();
        //if (defaultAccountId != null)
        // lead.AccountId = defaultAccountId;
        
        lead.Company='social studio';
        try{
            LIST<ACE_ServiceUtil.leadDetail> leadsToBeProcessed;
            ACE_LeadAPIService.processLeads(leadsToBeProcessed);
            
            //ACE_ServiceUtil.
            leadsToBeProcessed[0].leadData=lead;
            leadsToBeProcessed[0].leadStatus='Open - Not Contacted';
            
            insert lead; 
        }
        catch(system.DmlException e){
            system.debug('Insertion error'+e);
        }
        return lead;
    }
    
    private void handlePostAttachments(SocialPost post, Map<String, Object> rawData) {
        String attachmentRawData = JSON.serialize(rawData.get('mediaUrls'));
        if (String.isNotBlank(attachmentRawData)) {
            List<PostAttachment> attachments = (List<PostAttachment>) JSON.deserialize(attachmentRawData, List<PostAttachment>.class);
            if (attachments != null && !attachments.isEmpty()) {
                createAttachments(post, attachments);
            }
        }
    }
    
    private void createAttachments(SocialPost post, List<PostAttachment> attachments) {
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        for(PostAttachment attachment : attachments) {
            if (String.isNotBlank(attachment.mediaUrl) && attachment.mediaUrl != null && attachment.mediaUrl.length() <= ContentVersion.ContentUrl.getDescribe().getLength()) {
                ContentVersion contentVersion = new ContentVersion();
                contentVersion.contentUrl = attachment.mediaUrl;
                contentVersion.contentLocation = 'L';
                contentVersions.add(contentVersion);
            }
        }
        if (!contentVersions.isEmpty()) {
            insert(contentVersions);
            createLinksForAttachmentsToSocialPost(post, contentVersions);
        }
    }
    
    private void createLinksForAttachmentsToSocialPost(SocialPost post, List<ContentVersion> contentVersions) {
        List<Id> versionIds = new List<Id>(new Map<Id, ContentVersion>(contentVersions).keySet());
        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId IN :versionIds];
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        for(ContentDocument contentDocument : contentDocuments) {
            ContentDocumentLink contentDocLink = new ContentDocumentLink();
            contentDocLink.contentDocumentId = contentDocument.Id;
            contentDocLink.linkedEntityId = post.Id;
            contentDocLink.shareType = 'I';
            contentDocLink.visibility = 'AllUsers';
            contentDocumentLinks.add(contentDocLink);
        }
        if (!contentDocumentLinks.isEmpty()) {
            insert(contentDocumentLinks);
        }
    }
    
    public class PostAttachment {
        public String mediaType;
        public String mediaUrl;
        
        public PostAttachment(String mediaType, String mediaUrl) {
            this.mediaType = mediaType;
            this.mediaUrl = mediaUrl;
        }
    }
}