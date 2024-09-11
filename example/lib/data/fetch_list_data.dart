import 'package:example/data/api_res.dart';
import 'package:flutter_base/flutter_base.dart';

class ProjectEntity {
  final String? name;

  ProjectEntity.fromJson(Map<String, dynamic> json) : name = Normalize.initJsonString(json, 'name');
}

Future<ItemsResEntity<ProjectEntity>> fetchGetLists() async {
  final apiRes = ApiResModel.fromJson(sourceList);

  await Future.delayed(const Duration(milliseconds: 700));

  return ItemsResEntity<ProjectEntity>(
    success: true,
    status: ResStatus.success,
    items: apiRes.items?.map((e) => ProjectEntity.fromJson(e)).toList(),
    isNextAvailable: (oMeta != null && oMeta.nextPage != null),
  );
}

const sourceList = {
  "items": [
    {
      "id": "01j3yrgjkgrwybjgdsgr1qw38q",
      "user_id": "01ee0gjm0g55jst75h60nk3wqw",
      "name": "Hầm Đường Sắt Đô Thị Metro Line 3",
      "address": "Kim Mã - Hà Nội",
      "state": 1,
      "status": true,
      "created_at": "2024-07-29T08:08:06.000000Z",
      "machines": [
        {
          "id": "01j3yrhwk80sm5bg19b198nwhg",
          "name": "Thi Công Hầm",
          "state": 1,
          "image": {
            "id": "186ffb8d-986e-4538-a0ab-f8f637d45eb9",
            "name": "01990.jpg",
            "sensor": [
              {"name": "Nhiệt độ không khí", "code": "air_temp", "value": 28.1, "unit": "&#8451;", "unit2": "°C"},
              {"name": "Độ ẩm không khí", "code": "air_humid", "value": 64.48, "unit": "%", "unit2": "%"}
            ],
            "is_ci": 1,
            "date_shot": "2024-08-13T08:20:00.000000Z"
          }
        }
      ],
      "user": {"id": "01ee0gjm0g55jst75h60nk3wqw", "name": "ADMIN"},
      "is_owner": true
    },
    {
      "id": "01j2fqtqp0qb80qhp6yk9t7jnr",
      "user_id": "01ee0gjm0g55jst75h60nk3wqw",
      "name": "CTY TNHH Senao Networks Việt Nam",
      "address": "KCN Thái Hà, huyện Lý Nhân, tỉnh Hà Nam",
      "state": 1,
      "status": true,
      "created_at": "2024-07-11T01:51:52.000000Z",
      "machines": [
        {
          "id": "01j2fqw4kg40z73f4crgzz6npt",
          "name": "Nhà Xưởng",
          "state": 1,
          "image": {
            "id": "ba68a1ba-66f9-44b9-b049-a1d64b60f24f",
            "name": "07472.jpg",
            "sensor": [
              {"name": "Nhiệt độ không khí", "code": "air_temp", "value": 29.17, "unit": "&#8451;", "unit2": "°C"},
              {"name": "Độ ẩm không khí", "code": "air_humid", "value": 78.33, "unit": "%", "unit2": "%"}
            ],
            "is_ci": 1,
            "date_shot": "2024-09-11T08:00:00.000000Z"
          }
        }
      ],
      "user": {"id": "01ee0gjm0g55jst75h60nk3wqw", "name": "ADMIN"},
      "is_owner": true
    },
    {
      "id": "01j208xyb07y3bkstm09me9wec",
      "user_id": "01ee0gjm0g55jst75h60nk3wqw",
      "name": "Nhà máy TNHH Xuli Cargo Control Thái Bình",
      "address": "Lô CN-03, Khu công nghiệp Tiền Hải, thị trấn Tiền Hải, huyện Tiền Hải, tỉnh Thái Bình",
      "state": 1,
      "status": true,
      "created_at": "2024-07-05T01:42:52.000000Z",
      "machines": [
        {
          "id": "01j2090w30kxd2e9pyq4chmggf",
          "name": "Nhà Máy Góc 1",
          "state": 1,
          "image": {
            "id": "aed11526-751d-45b1-b2a0-0b89e2a4556f",
            "name": "08346.jpg",
            "sensor": [
              {"name": "Nhiệt độ không khí", "code": "air_temp", "value": 31.35, "unit": "&#8451;", "unit2": "°C"},
              {"name": "Độ ẩm không khí", "code": "air_humid", "value": 74.51, "unit": "%", "unit2": "%"}
            ],
            "is_ci": 1,
            "date_shot": "2024-09-11T08:00:00.000000Z"
          }
        },
        {
          "id": "01j2092pp0r5ak0tv1z8trrb20",
          "name": "Nhà Máy Góc 2",
          "state": 1,
          "image": {
            "id": "4f509e1f-3bdd-43ca-b15e-9bdce0e67523",
            "name": "09220.jpg",
            "sensor": [
              {"name": "Nhiệt độ không khí", "code": "air_temp", "value": 35.87, "unit": "&#8451;", "unit2": "°C"},
              {"name": "Độ ẩm không khí", "code": "air_humid", "value": 57.1, "unit": "%", "unit2": "%"}
            ],
            "is_ci": 1,
            "date_shot": "2024-09-11T07:48:00.000000Z"
          }
        }
      ],
      "user": {"id": "01ee0gjm0g55jst75h60nk3wqw", "name": "ADMIN"},
      "is_owner": true
    },
    {
      "id": "01j17172qg0re5z95jjjj2ns84",
      "user_id": "01ee0gjm0g55jst75h60nk3wqw",
      "name": "Nhà máy kết cấu thép Hải Long",
      "address": "Chân cầu Tiên Cựu, xã Đại Thắng, huyện Tiên Lãng, TP.Hải Phòng",
      "state": 1,
      "status": true,
      "created_at": "2024-06-25T06:27:02.000000Z",
      "machines": [
        {
          "id": "01j1719smr3gr6w4k1bkekjckp",
          "name": "Nhà xưởng",
          "state": 1,
          "image": {"id": "dda10b42-e8fa-477b-b2d4-59fbf1721e63", "name": "48839.jpg", "is_ci": 1, "date_shot": "2024-08-25T04:25:48.000000Z"}
        }
      ],
      "user": {"id": "01ee0gjm0g55jst75h60nk3wqw", "name": "ADMIN"},
      "is_owner": true
    },
    {
      "id": "01j12m4470vmqdxfnrkhr9k8m6",
      "user_id": "01ee0gjm0g55jst75h60nk3wqw",
      "name": "Vegastar",
      "address": "79 Văn Tiến Dũng",
      "state": 1,
      "status": true,
      "created_at": "2024-06-23T13:21:16.000000Z",
      "machines": [
        {
          "id": "01j12m5c88zmedyvejwzdfjj17",
          "name": "Vegastar Góc 1",
          "state": 1,
          "image": {"id": "c2743ac8-88e5-4639-86d8-551c17504720", "name": "14152.jpg", "is_ci": 1, "date_shot": "2024-06-27T07:02:38.000000Z"}
        },
        {
          "id": "01j12m5zs8ty3kj7p7a57y6zfd",
          "name": "Vegastar Góc 2",
          "state": 1,
          "image": {
            "id": "ba3e5381-32c2-49f5-8de6-76b246714238",
            "name": "13795.jpg",
            "sensor": [
              {"name": "Nhiệt độ không khí", "code": "air_temp", "value": 39.62, "unit": "&#8451;", "unit2": "°C"},
              {"name": "Độ ẩm không khí", "code": "air_humid", "value": 73.2, "unit": "%", "unit2": "%"}
            ],
            "is_ci": 1,
            "date_shot": "2024-06-28T02:30:00.000000Z"
          }
        }
      ],
      "user": {"id": "01ee0gjm0g55jst75h60nk3wqw", "name": "ADMIN"},
      "is_owner": true
    },
    {
      "id": "01hzkt956gpeby1ddwr8j4640h",
      "user_id": "01ee0gjm0g55jst75h60nk3wqw",
      "name": "Hương Sơn Konnection",
      "address": "Hương Sơn, Mỹ Đức, Hà Nội",
      "state": 1,
      "status": true,
      "created_at": "2024-06-05T09:04:34.000000Z",
      "machines": [
        {
          "id": "01hzktab98rx2rb5a5mr691bce",
          "name": "Hương Sơn Konnection",
          "state": 1,
          "image": {
            "id": "d2d6c131-e9d9-4bda-b4a4-d85e13e76953",
            "name": "06293.jpg",
            "sensor": [
              {"name": "Nhiệt độ không khí", "code": "air_temp", "value": 30.34, "unit": "&#8451;", "unit2": "°C"},
              {"name": "Độ ẩm không khí", "code": "air_humid", "value": 96.35, "unit": "%", "unit2": "%"}
            ],
            "is_ci": 1,
            "date_shot": "2024-09-11T08:00:00.000000Z"
          }
        }
      ],
      "user": {"id": "01ee0gjm0g55jst75h60nk3wqw", "name": "ADMIN"},
      "is_owner": true
    },
    {
      "id": "01hywh92cgdh068extmbhcv5qc",
      "user_id": "01ee0gjm0g55jst75h60nk3wqn",
      "name": "Shophouse Hòn Thơm",
      "address": "Phú Quốc",
      "state": 1,
      "status": true,
      "created_at": "2024-05-27T08:04:42.000000Z",
      "machines": [
        {
          "id": "01hywhaj7r3yavcvm4t6g1e1za",
          "name": "Shophouse Hòn Thơm",
          "state": 1,
          "image": {
            "id": "06d2bd04-4d3e-4817-9019-2dad8bfdbca2",
            "name": "11902.jpg",
            "sensor": [
              {"name": "Nhiệt độ không khí", "code": "air_temp", "value": 34.33, "unit": "&#8451;", "unit2": "°C"},
              {"name": "Độ ẩm không khí", "code": "air_humid", "value": 80.78, "unit": "%", "unit2": "%"}
            ],
            "is_ci": 1,
            "date_shot": "2024-09-11T08:00:00.000000Z"
          }
        }
      ],
      "user": {"id": "01ee0gjm0g55jst75h60nk3wqn", "name": "SUN GROUP"},
      "is_owner": false
    },
    {
      "id": "01hyvvcs6r0dfd23g7e0he9r90",
      "user_id": "01ee0gjm0g55jst75h60nk3wqw",
      "name": "Nhà Xưởng Shinzu Shing Bắc Giang",
      "address": "Lô CN-04 KCN Hòa Phú, xã Mai Đình, huyện Hiệp Hòa, tỉnh Bắc Giang",
      "state": 1,
      "status": true,
      "created_at": "2024-05-27T01:42:15.000000Z",
      "machines": [
        {
          "id": "01hyvveb0g5becgg2v5gjtdsaf",
          "name": "Nhà Xưởng Shinzu Shing",
          "state": 1,
          "image": {
            "id": "755ccc45-404a-4677-b95f-bfb88125626b",
            "name": "07827.jpg",
            "sensor": [
              {"name": "Nhiệt độ không khí", "code": "air_temp", "value": 31.2, "unit": "&#8451;", "unit2": "°C"},
              {"name": "Độ ẩm không khí", "code": "air_humid", "value": 79.61, "unit": "%", "unit2": "%"}
            ],
            "is_ci": 1,
            "date_shot": "2024-09-11T07:45:00.000000Z"
          }
        }
      ],
      "user": {"id": "01ee0gjm0g55jst75h60nk3wqw", "name": "ADMIN"},
      "is_owner": true
    },
    {
      "id": "01hyf8w4hgaq9an8jehtwwvwn1",
      "user_id": "01ee0gjm0g55jst75h60nk3wqn",
      "name": "SUN - OLALANI Đà Nẵng",
      "address": "Khách sạn Novotel",
      "state": 1,
      "status": true,
      "created_at": "2024-05-22T04:27:42.000000Z",
      "machines": [
        {
          "id": "01hyf97dw03dz4r3detyekapzp",
          "name": "OLALANI",
          "state": 1,
          "image": {
            "id": "a340adab-7461-4c49-b458-cdf6fca9e429",
            "name": "15091.jpg",
            "sensor": [
              {"name": "Nhiệt độ không khí", "code": "air_temp", "value": 40.92, "unit": "&#8451;", "unit2": "°C"},
              {"name": "Độ ẩm không khí", "code": "air_humid", "value": 55.44, "unit": "%", "unit2": "%"}
            ],
            "is_ci": 1,
            "date_shot": "2024-09-11T08:00:00.000000Z"
          }
        }
      ],
      "user": {"id": "01ee0gjm0g55jst75h60nk3wqn", "name": "SUN GROUP"},
      "is_owner": false
    },
    {
      "id": "01hyf8tcw8meza3ec9sxg4549j",
      "user_id": "01ee0gjm0g55jst75h60nk3wqn",
      "name": "SUN - HH3 Đà Nẵng",
      "address": "Đài Phát Thanh Truyền Hình Đà Nẵng - Fivitel DaNang Hotel",
      "state": 1,
      "status": true,
      "created_at": "2024-05-22T04:26:45.000000Z",
      "machines": [
        {
          "id": "01hyf96bp8b15wz7gpv4t2m5tm",
          "name": "HH3 Đà Nẵng Góc 1",
          "state": 1,
          "image": {
            "id": "ee2dcfb6-1644-4d3b-a260-9cadaecce52e",
            "name": "22427.jpg",
            "sensor": [
              {"name": "Nhiệt độ không khí", "code": "air_temp", "value": 34.72, "unit": "&#8451;", "unit2": "°C"},
              {"name": "Độ ẩm không khí", "code": "air_humid", "value": 69.97, "unit": "%", "unit2": "%"}
            ],
            "is_ci": 1,
            "date_shot": "2024-09-11T08:00:00.000000Z"
          }
        },
        {
          "id": "01j02r8fcrycpznd9zc8e5s686",
          "name": "HH3 Đà Nẵng Góc 2",
          "state": 1,
          "image": {
            "id": "f2fc8504-0e81-411a-b551-ce71e405fea3",
            "name": "13644.jpg",
            "sensor": [
              {"name": "Nhiệt độ không khí", "code": "air_temp", "value": 35.57, "unit": "&#8451;", "unit2": "°C"},
              {"name": "Độ ẩm không khí", "code": "air_humid", "value": 57.51, "unit": "%", "unit2": "%"}
            ],
            "is_ci": 1,
            "date_shot": "2024-09-11T08:00:00.000000Z"
          }
        }
      ],
      "user": {"id": "01ee0gjm0g55jst75h60nk3wqn", "name": "SUN GROUP"},
      "is_owner": false
    },
    {
      "id": "01hyf8pwjggjwwmvqyfxnhzxcc",
      "user_id": "01ee0gjm0g55jst75h60nk3wqn",
      "name": "SUN - COSMO PANOMA ĐÀ NẴNG",
      "address": "Fivitel DaNang Hotel",
      "state": 1,
      "status": true,
      "created_at": "2024-05-22T04:24:50.000000Z",
      "machines": [
        {
          "id": "01hyf8yycgt1wfr9xmq39km5xy",
          "name": "Cosmo Panoma",
          "state": 1,
          "image": {
            "id": "b3a7a4df-b5cc-4161-9f4c-2c465da8c261",
            "name": "11522.jpg",
            "sensor": [
              {"name": "Nhiệt độ không khí", "code": "air_temp", "value": 36.77, "unit": "&#8451;", "unit2": "°C"},
              {"name": "Độ ẩm không khí", "code": "air_humid", "value": 69.31, "unit": "%", "unit2": "%"}
            ],
            "is_ci": 1,
            "date_shot": "2024-09-11T08:00:00.000000Z"
          }
        }
      ],
      "user": {"id": "01ee0gjm0g55jst75h60nk3wqn", "name": "SUN GROUP"},
      "is_owner": false
    },
    {
      "id": "01hy262mwgsyaxscz0dd5h98xn",
      "user_id": "01ee0gjm0g55jst75h60nk3wqw",
      "name": "Học Viện Hậu Cần Gia Lâm",
      "address": "Gia Lâm Hà Nội",
      "state": 1,
      "status": true,
      "created_at": "2024-05-17T02:28:42.000000Z",
      "machines": [
        {
          "id": "01hy2674e8z8x6981f9kmfqqtp",
          "name": "Học Viện Hậu Cần Gia Lâm",
          "state": 1,
          "image": {
            "id": "54367fd4-b802-4856-b40b-dfaf1a474001",
            "name": "07423.jpg",
            "sensor": [
              {"name": "Nhiệt độ không khí", "code": "air_temp", "value": 28.44, "unit": "&#8451;", "unit2": "°C"},
              {"name": "Độ ẩm không khí", "code": "air_humid", "value": 99.99, "unit": "%", "unit2": "%"}
            ],
            "is_ci": 1,
            "date_shot": "2024-07-23T06:00:00.000000Z"
          }
        },
        {
          "id": "01j3m8e31rk884q9dg0p4wttg2",
          "name": "Học Viện Hậu Cần Gia Lâm Góc 1.1",
          "state": 1,
          "image": {
            "id": "5d956270-f77d-4279-b7d4-737dfc6af594",
            "name": "05905.jpg",
            "sensor": [
              {"name": "Nhiệt độ không khí", "code": "air_temp", "value": 30.34, "unit": "&#8451;", "unit2": "°C"},
              {"name": "Độ ẩm không khí", "code": "air_humid", "value": 89.64, "unit": "%", "unit2": "%"}
            ],
            "is_ci": 1,
            "date_shot": "2024-09-11T08:00:00.000000Z"
          }
        }
      ],
      "user": {"id": "01ee0gjm0g55jst75h60nk3wqw", "name": "ADMIN"},
      "is_owner": true
    }
  ],
  "_meta": {"per_page": 12, "total_count": 250, "page_count": 21, "current_page": 1, "next_page": 2},
  "code": 200,
  "success": true
};
