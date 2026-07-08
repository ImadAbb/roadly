class PLData {

  String pourcentage;
  String essieuxSimples;
  String essieuxTandems;


  PLData({
    required this.pourcentage,
    required this.essieuxSimples,
    required this.essieuxTandems,
  });


  PLData copy(){

    return PLData(
      pourcentage: pourcentage,
      essieuxSimples: essieuxSimples,
      essieuxTandems: essieuxTandems,
    );

  }

}