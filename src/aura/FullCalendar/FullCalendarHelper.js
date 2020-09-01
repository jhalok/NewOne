({
    loadDataToCalendar :function(component,data){ 
        component.set("v.events", data);       
        var ele = component.find('calendar').getElement();
        $(ele).fullCalendar('rerenderEvents');
        /*component.find('calendar').getElement().fullCalendar('renderEvent',{
                header: {
                    left: 'prev,next today',
                    center: 'title',
                    right: 'month,basicWeek,basicDay'
                },
                defaultDate: '2016-04-01',
                editable: true,
                eventLimit: true,
                events:data
            });*/
    },
    
    tranformToFullCalendarFormat : function(component,events,id) {
        var eventArr = [];
        for(var i = 0;i < events.length;i++){
            
            if(events[i].Test_Drive_by__c == id){
                var title ;
                if(events[i].Model__r != null){
                    title = events[i].Name +' \n '+  events[i].Model__r.Name;
                }
                else{
                    title = events[i].Name;
                }
                eventArr.push({
                    'id':events[i].Id,
                    'title' : title,
                    'start':events[i].Start_Date_Time__c,
                    'end':events[i].End_Date_Time__c,
                    
                    'backgroundColor' : 'yellow',
                    'textColor': 'black',
                }); 
            }
            else{
               
                var title ;
                if(events[i].Model__r != null){
                    title = events[i].Name +' \n '+  events[i].Model__r.Name;
                }
                else{
                    title = events[i].Name;
                }
                eventArr.push({
                    'id':events[i].Id,
                    'title' :title ,
                    'start':events[i].Start_Date_Time__c,
                    'end':events[i].End_Date_Time__c,
                    
                });  
            }
            
        }
        return eventArr;
    },
    
    fetchEvents : function(component) {
        var str = window.location.href
        var res = str.split("/");
        var action = component.get("c.getEvents"); 
        action.setParams({ Id : res[6] });
        var self = this;
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS"){
                
                var eventArr = self.tranformToFullCalendarFormat(component,response.getReturnValue(),res[6]);
                var ele = component.find('calendar').getElement();
                var calendar = new FullCalendar.Calendar(ele, {
                    plugins: [ 'interaction','timeGrid' ],
                    defaultView: 'timeGridWeek',
                    editable: true,
                    allDaySlot: false,
                    eventLimit: true,
                    
                    // allow "more" link when too many events
                    dateClick: function(info) {
                        
                        console.log(info.event);
                        var end_time = info.dateStr; 
                        var End_date = new Date(Date.parse(end_time));
                        End_date.setDate(End_date.getDate());
                        component.set('v.startDate', End_date.toISOString());
                        End_date.setHours( End_date.getHours() + 1 );
                        component.set('v.endDate', End_date.toISOString());
                        component.set("v.isOpen", true);
                    },
                    events: eventArr ,
                });
                
                calendar.render();
                component.set("v.events",eventArr);
                
            }
            
        });
        
        $A.enqueueAction(action); 
        
    }, 
})