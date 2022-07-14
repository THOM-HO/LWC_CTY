global class BatchStudent implements Database.Batchable<SObject>, Database.Stateful, Schedulable{
    
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new BatchStudent(), 2);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            [SELECT Id, Diem1__c, Diem2__c, Diem3__c FROM HocSinh__c]
        );
    }
    global void execute(Database.BatchableContext bc, List<HocSinh__c> records){
        List<Diem__c> listPoint1 =  new List<Diem__c>();
        listPoint = [SELECT Id, Diem__c, HocSinh__c,Mon__c FROM Diem__c WHERE HocSinh__c IN :records];
        
        Map<String,List<Diem__c>> mapPoint= new Map<String,List<Diem__c>>();
        mapPoint= mapPointById(listPoint);

        List<Diem__c> listPointUpdate =  new List<Diem__c>();
        for (HocSinh__c student : records) {
            List<Diem__c> list = mapPoint.get(student.Id);
           Boolean flagHoa= false;
           Boolean flagLy= false;
           Boolean flagToan= false;
            for(Diem__c diem: list){
                if(diem.Mon__c.equals('Hóa') && diem.Diem__c.equals(student.Diem1__c)){
                    flagHoa =true;
                }
                if(diem.Mon__c.equals('Lý')  && diem.Diem__c.equals(student.Diem2__c)){
                    flagLy =true;
                }
                if(diem.Mon__c.equals('Toán')  && diem.Diem__c.equals(student.Diem3__c)){
                    flagToan =true;
                }
            }

            if(flagHoa === false){
                listPoint.add(new Diem__c(student.Id, student.Diem1__c, 'Hóa'));
            }
            if(flagLy === false){
                listPoint.add(new Diem__c(student.Id, student.Diem2__c, 'Lý'));
            }
            if(flagToan === false){
                listPoint.add(new Diem__c(student.Id, student.Diem3__c, 'Toán'));
            }
          }
        upsert listPoint;
    }

    global void finish(Database.BatchableContext bc){
       System.debug('Done');
    }

    global Map<String,List<Diem__c>> mapPointById(List<Diem__c> listPoint) {
        Map<String, List<Diem__c>> listMap = new  Map<String, List<Diem__c>>();
        for(Diem__c point : listPoint){
           if (!listMap.containsKey(point.HocSinh__c)) {
            List<Diem__c> points = new List<Diem__c>();
            points.add(point);
            listMap.put(point.HocSinh__c,points);
           } else{
           listMap.get(point.HocSinh__c).add(point);
           }
        }
    }
}
