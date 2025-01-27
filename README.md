# Example นี้มีชื่อว่า ble_ancs
โดยการทำงานของ Example นี้คือจะดักจับการแจ้งเตือนต่างๆในโทรศัพท์ ios ผ่าน bluetooth
#
ขั้นตอนแรกเลือก Example
# ![image](https://github.com/user-attachments/assets/1cf54d4a-ff14-45a0-be08-352ce71fc0fb)
รันและbuildโปรแกรม
# ![cookbook1](https://github.com/user-attachments/assets/8d49ac3e-c419-40cf-b21a-670c725b9400)
หลังจากนั้นนำโทรศัพท์ ios เชื่อมต่อบลูทูธกับ esp
# ![S__14123016](https://github.com/user-attachments/assets/d9fad878-19f8-40e7-b3e2-13dce68f1e50)
แล้วตัวโปรแกรมจะดักจับการแจ้งเตือนจากโทรศัพท์ ios
# ![cookbook2](https://github.com/user-attachments/assets/67c84faa-ad1d-4c84-8df6-cb51cad358a3)
จากภาพเป็นการดักจับเมื่อมีคนโทรเข้ามา

## แก้ไขเพิ่มเติม
แก้โดยเปลี่ยนฟังก์ชั่นที่แสดงที่ OUTPUT เป็นภาษาไทยให้เข้าใจได้ง่ายขึ้น
```
  /*
 * SPDX-FileCopyrightText: 2021-2022 Espressif Systems (Shanghai) CO LTD
 *
 * SPDX-License-Identifier: Unlicense OR CC0-1.0
 */

#include <stdlib.h>
#include <string.h>
#include <inttypes.h>
#include "esp_log.h"
#include "ble_ancs.h"

#define BLE_ANCS_TAG  "BLE_ANCS"

// ... (ส่วนที่เหลือของโค้ดยังคงเดิม)

char *EventID_to_String(uint8_t EventID) {
    char *str = NULL;
    switch (EventID) {
        case EventIDNotificationAdded:
            str = "ข้อความใหม่";
            break;
        case EventIDNotificationModified:
            str = "ข้อความที่ถูกปรับเปลี่ยน";
            break;
        case EventIDNotificationRemoved:
            str = "ข้อความที่ถูกลบ";
            break;
        default:
            str = "EventID ไม่ทราบ";
            break;
    }
    return str;
}

char *CategoryID_to_String(uint8_t CategoryID) {
    char *Cidstr = NULL;
    switch(CategoryID) {
        case CategoryIDOther:
            Cidstr = "อื่นๆ";
            break;
        case CategoryIDIncomingCall:
            Cidstr = "โทรเข้า";
            break;
        case CategoryIDMissedCall:
            Cidstr = "โทรที่พลาด";
            break;
        case CategoryIDVoicemail:
            Cidstr = "ข้อความเสียง";
            break;
        case CategoryIDSocial:
            Cidstr = "โซเชียล";
            break;
        case CategoryIDSchedule:
            Cidstr = "ตารางเวลา";
            break;
        case CategoryIDEmail:
            Cidstr = "อีเมล";
            break;
        case CategoryIDNews:
            Cidstr = "ข่าว";
            break;
        case CategoryIDHealthAndFitness:
            Cidstr = "สุขภาพและฟิตเนส";
            break;
        case CategoryIDBusinessAndFinance:
            Cidstr = "ธุรกิจและการเงิน";
            break;
        case CategoryIDLocation:
            Cidstr = "ตำแหน่ง";
            break;
        case CategoryIDEntertainment:
            Cidstr = "บันเทิง";
            break;
        default:
            Cidstr = "CategoryID ไม่ทราบ";
            break;
    }
    return Cidstr;
}

void esp_receive_apple_notification_source(uint8_t *message, uint16_t message_len) {
    if (!message || message_len < 5) {
        return;
    }

    uint8_t EventID    = message[0];
    char    *EventIDS  = EventID_to_String(EventID);
    uint8_t EventFlags = message[1];
    uint8_t CategoryID = message[2];
    char    *Cidstr    = CategoryID_to_String(CategoryID);
    uint8_t CategoryCount = message[3];
    uint32_t NotificationUID = (message[4]) | (message[5] << 8) | (message[6] << 16) | (message[7] << 24);
    ESP_LOGI(BLE_ANCS_TAG, "EventID: %s EventFlags: 0x%x CategoryID: %s CategoryCount: %d NotificationUID: %" PRIu32, EventIDS, EventFlags, Cidstr, CategoryCount, NotificationUID);
}

void esp_receive_apple_data_source(uint8_t *message, uint16_t message_len) {
    if (!message || message_len == 0) {
        return;
    }
    
    uint8_t Command_id = message[0];
    switch (Command_id) {
        case CommandIDGetNotificationAttributes: {
            uint32_t NotificationUID = (message[1]) | (message[2] << 8) | (message[3] << 16) | (message[4] << 24);
            uint32_t remian_attr_len = message_len - 5;
            uint8_t *attrs = &message[5];
            ESP_LOGI(BLE_ANCS_TAG, "รับข้อมูลคุณสมบัติการแจ้งเตือน Command_id %d NotificationUID %" PRIu32, Command_id, NotificationUID);
            while(remian_attr_len > 0) {
                uint8_t AttributeID = attrs[0];
                uint16_t len = attrs[1] | (attrs[2] << 8);
                if (len > (remian_attr_len - 3)) {
                    ESP_LOGE(BLE_ANCS_TAG, "ข้อมูลผิดพลาด");
                    break;
                }
                switch (AttributeID) {
                    case NotificationAttributeIDAppIdentifier:
                        esp_log_buffer_char("Identifier", &attrs[3], len);
                        break;
                    case NotificationAttributeIDTitle:
                        esp_log_buffer_char("Title", &attrs[3], len); // ตรวจสอบให้แน่ใจว่าสามารถจัดการกับสตริง UTF-8 ที่ยาวได้
                        break;
                    case NotificationAttributeIDSubtitle:
                        esp_log_buffer_char("Subtitle", &attrs[3], len);
                        break;
                    case NotificationAttributeIDMessage:
                        esp_log_buffer_char("Message", &attrs[3], len); // ตรวจสอบให้แน่ใจว่าสามารถจัดการกับสตริง UTF-8 ที่ยาวได้
                        break;
                    case NotificationAttributeIDMessageSize:
                        esp_log_buffer_char("MessageSize", &attrs[3], len);
                        break;
                    case NotificationAttributeIDDate:
                        esp_log_buffer_char("Date", &attrs[3], len);
                        break;
                    case NotificationAttributeIDPositiveActionLabel:
                        esp_log_buffer_hex("PActionLabel", &attrs[3], len);
                        break;
                    case NotificationAttributeIDNegativeActionLabel:
                        esp_log_buffer_hex("NActionLabel", &attrs[3], len);
                        break;
                    default:
                        esp_log_buffer_hex("unknownAttributeID", &attrs[3], len);
                        break;
                }

                attrs += (1 + 2 + len);
                remian_attr_len -= (1 + 2 + len);
            }
            break;
        }
        case CommandIDGetAppAttributes:
            ESP_LOGI(BLE_ANCS_TAG, "รับข้อมูลคุณสมบัติของแอป");
            break;
        case CommandIDPerformNotificationAction:
            ESP_LOGI(BLE_ANCS_TAG, "รับการดำเนินการแจ้งเตือน");
            break;
        default:
            ESP_LOGI(BLE_ANCS_TAG, "Command ID ไม่ทราบ");
            break;
    }
}

char *Errcode_to_String(uint16_t status) {
    char *Errstr = NULL;
    switch (status) {
        case Unknown_command:
            Errstr = "คำสั่งไม่รู้จัก";
            break;
        case Invalid_command:
            Errstr = "คำสั่งไม่ถูกต้อง";
            break;
        case Invalid_parameter:
            Errstr = "พารามิเตอร์ไม่ถูกต้อง";
            break;
        case Action_failed:
            Errstr = "การดำเนินการล้มเหลว";
            break;
        default:
            Errstr = "ข้อผิดพลาดไม่รู้จัก";
            break;
    }
    return Errstr;
}

```
ได้ผลลัพธ์ดังนี้ 
# ![cookbook3](https://github.com/user-attachments/assets/c4650e3a-de34-4f73-a0b0-f2a46a2d9bf7)

