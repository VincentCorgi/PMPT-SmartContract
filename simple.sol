// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

contract Simple {
    //variable
    //廠商
    struct Manufacturer {
        address addr; // 廠商地址
        string name; // 廠商名稱
        string contact; // 聯絡人
        string contactNumber; // 聯絡電話
        string contanctAddress; // 聯絡地址
        string email; // 電子郵件
    }
    // 標案
    struct Tender {
        address addr; // 營造廠商
        uint id; // 標案編號
        string name; // 標案名稱
        uint procurementProperty; // 採購性質
        uint tenderMethod; // 招標方式
        string publishingDate; // 公告日
        uint budgetAmount; // 預算金額
        string biddingDeadline; // 截止日期
        string openingDate; // 開標時間
        address[] biddersAddress; // 投標廠商
        mapping (address => Bidder) bidders; // 投標資料
    }
    // 投標資料
    struct Bidder {
        address addr; // 競標商
        uint price; // 投標金額
        string exerciseDate; // 履約日期 
        bool isSME; // 是否為中小型企業
    }
    
    mapping (address => Manufacturer) public ManufacturerList;
    mapping (uint => Tender) public tenderList;
    uint public amountTender = 0;

    //function
    // 新增廠商
    function addManufacturer(
        string memory name,
        string memory email,
        string memory contact,
        string memory contactNumber,
        string memory contanctAddress
    ) public {
        ManufacturerList[msg.sender] = Manufacturer(msg.sender, name, contact, contactNumber, contanctAddress, email)
    }
    // 新增標案
    function addTender(
        string memory name,
        uint procurementProperty,
        uint tenderMethod,
        string memory publishingDate,
        uint budgetAmount,
        string memory biddingDeadline,
        string memory openingDate
    ) public {
        Tender storage tender = tenderList[amountTender];
        tender.addr = msg.sender;
        tender.id = amountTender;
        tender.name = name;
        tender.procurementProperty = procurementProperty;
        tender.tenderMethod = tenderMethod;
        tender.publishingDate = publishingDate;
        tender.budgetAmount = budgetAmount;
        tender.biddingDeadline = biddingDeadline;
        tender.openingDate = openingDate;
        amountTender++;
    }
    // 新增投標
    function addTenderBidder(
        uint tenderId,
        uint price,
        string memory exerciseDate,
        bool isSME
    ) public {
        tenderList[tenderId].biddersAddress.push(msg.sender);
        tenderList[tenderId].bidders[msg.sender].addr = msg.sender;
        tenderList[tenderId].bidders[msg.sender].price = price;
        tenderList[tenderId].bidders[msg.sender].exerciseDate = exerciseDate;
        tenderList[tenderId].bidders[msg.sender].isSME = isSME;
    }
    // 新增投標資訊投標資訊
    function lookupBidder(
        uint tenderId,
        address addr
    ) public view returns(
        address,
        uint,
        string memory,
        bool
    ) {
        require(addr == tenderList[tenderId].bidders[addr].addr, "This Address was not involved in the tender");
        return (
            tenderList[tenderId].bidders[addr].addr,
            tenderList[tenderId].bidders[addr].price,
            tenderList[tenderId].bidders[addr].exerciseDate,
            tenderList[tenderId].bidders[addr].isSME
        );
    }
    // 查詢所有競標商地址
    function getBiddersAddress(uint tenderId) public view returns (address[] memory) {
        return tenderList[tenderId].biddersAddress;
    }
    // 選出得標商得標商
    function selectedAwardBidder(uint tenderId) public {
        Bidder memory awardBidder;
        Tender storage tender = tenderList[tenderId];
        for (uint i = 0; i < tender.biddersAddress.length; i++) {
            address addr = tender.biddersAddress[i];
            Bidder memory bidder = tender.bidders[addr];
            if (awardBidder.price ==0 ) {
                awardBidder = bidder;
            }
            if (bidder.price < awardBidder.price) {
                awardBidder = bidder;
            }
        }
        tender.sate = true;
        tender.awardBidder = awardBidder;
    }
}