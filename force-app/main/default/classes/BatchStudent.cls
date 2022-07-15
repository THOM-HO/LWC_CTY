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
        List<Diem__c> listPoints =  new List<Diem__c>();
        listPoints = [SELECT Id, Diem__c, HocSinh__c, Mon__c FROM Diem__c WHERE HocSinh__c IN :records];
        
        Map<String, List<Diem__c>> mapPoint= new Map<String, List<Diem__c>>();
        mapPoint= mapPointById(listPoints);

        List<Diem__c> listPointUpdate =  new List<Diem__c>();
        if(mapPoint.size() != 0 ){
            System.debug('Khac 0');
            for (HocSinh__c student : records) {
                List<Diem__c> listPoint = mapPoint.get(student.Id);

                if (listPoint.size() != 0) {
                    Boolean flagHoa = true;
                    Boolean flagLy = true;
                    Boolean flagToan= true;

                    for(Diem__c point : listPoint){
                      
                        if(point.Mon__c == 'Hóa'){
                            flagHoa = false; 
                            if(point.Diem__c != student.Diem1__c){
                                listPointUpdate.add(new Diem__c(Id = point.Id, Diem__c = student.Diem1__c));
                            }
                        }
                        if(point.Mon__c == 'Lý'){
                            flagLy = false;
                            if(point.Diem__c != student.Diem2__c){
                                listPointUpdate.add(new Diem__c(Id = point.Id, Diem__c = student.Diem2__c));
                            }
                        }
                        if(point.Mon__c == 'Toán'){
                            flagToan = false; 
                            if(point.Diem__c != student.Diem3__c){
                                listPointUpdate.add(new Diem__c(Id = point.Id, Diem__c = student.Diem3__c));
                            }
                        }
                    }

                    if(flagHoa == true){
                        listPointUpdate.add(new Diem__c(HocSinh__c = student.Id, Diem__c = student.Diem1__c, Mon__c = 'Hóa'));
                    }
                    if(flagLy == true){
                        listPointUpdate.add(new Diem__c(HocSinh__c = student.Id, Diem__c = student.Diem2__c, Mon__C = 'Lý'));
                    }
                    if(flagToan == true){
                        listPointUpdate.add(new Diem__c(HocSinh__c = student.Id, Diem__c = student.Diem2__c, Mon__C = 'Toán'));
                    }
                } else {
                    listPointUpdate.add(new Diem__c(HocSinh__c = student.Id, Diem__c = student.Diem1__c, Mon__c = 'Hóa'));
                    listPointUpdate.add(new Diem__c(HocSinh__c = student.Id, Diem__c = student.Diem2__c, Mon__C = 'Lý'));
                    listPointUpdate.add(new Diem__c(HocSinh__c = student.Id, Diem__c = student.Diem3__c, Mon__c = 'Toán'));
                }
            }
        } else {
            System.debug('rc'+records.size());
            for (HocSinh__c student : records) {
                listPointUpdate.add(new Diem__c(HocSinh__c = student.Id, Diem__c = student.Diem1__c, Mon__c = 'Hóa'));
                listPointUpdate.add(new Diem__c(HocSinh__c = student.Id, Diem__c = student.Diem2__c, Mon__C = 'Lý'));
                listPointUpdate.add(new Diem__c(HocSinh__c = student.Id, Diem__c = student.Diem3__c, Mon__c = 'Toán'));
            }
        }
        upsert listPointUpdate;
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
        return listMap;
    }
}

// List<Diem__c> lista= [SELECT Id FROM Diem__c];
// delete lista;
//Database.executeBatch(new BatchStudent(), 2);