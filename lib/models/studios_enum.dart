/// All of the studios of the SMStretching.
enum SMStretchingStudios {
  /// See: https://smstretching.ru/allstudios/studiya-na-chistih-prudah/
  studiyaNaChistihPrudah,

  /// See: https://smstretching.ru/allstudios/studiya-park-kultury/
  studiyaParkKultury,

  /// See: https://smstretching.ru/allstudios/chehovskaya/
  chehovskaya,

  /// See: https://smstretching.ru/allstudios/prospekt_mira/
  prospektMira,

  /// See: https://smstretching.ru/allstudios/studiya-na-tulskoy/
  studiyaNaTulskoy,
}

/// All of the data of the studios of the SMStretching.
extension SMStretchingStudiosData on SMStretchingStudios {
  /// The id of this studio.
  int get id {
    switch (this) {
      case SMStretchingStudios.studiyaNaChistihPrudah:
        return 193064;
      case SMStretchingStudios.studiyaParkKultury:
        return 455924;
      case SMStretchingStudios.chehovskaya:
        return 456372;
      case SMStretchingStudios.prospektMira:
        return 456379;
      case SMStretchingStudios.studiyaNaTulskoy:
        return 456384;
    }
  }
}
