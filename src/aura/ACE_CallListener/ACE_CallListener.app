<aura:application extends="ltng:outApp" >
    <lightning:empApi aura:id="empApi"/>
    <aura:attribute name="channel" type="String" default="/event/Notification__e"/>
    <aura:attribute name="subscription" type="Map"/>
</aura:application>